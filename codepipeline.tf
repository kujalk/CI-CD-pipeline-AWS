//Code Commit
resource "aws_codecommit_repository" "repo" {
  repository_name = var.RepoName
  description     = "This is the Sample CI/CD Demo repo"
}

//Code Build
resource "aws_s3_bucket" "BuildS3" {
  bucket        = "demo-jana-s3build"
  acl           = "private"
  force_destroy = true
}

resource "aws_codebuild_project" "code-build" {
  name         = "demo-build"
  description  = "Demo CI/CD Build phase"
  service_role = aws_iam_role.CodeBuild_Role.arn

  artifacts {
    type      = "S3"
    packaging = "ZIP"
    location  = aws_s3_bucket.BuildS3.bucket
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:2.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
  }

  source {
    type            = "CODECOMMIT"
    location        = aws_codecommit_repository.repo.clone_url_http
    git_clone_depth = 1
  }

  logs_config {
    cloudwatch_logs {
      status = "DISABLED"
    }
  }

}

//Code Deploy
resource "aws_codedeploy_app" "demo-deploy" {
  compute_platform = "Server"
  name             = "demo-deploy"
}

resource "aws_codedeploy_deployment_group" "demo-dev-deploy-group" {
  app_name              = aws_codedeploy_app.demo-deploy.name
  deployment_group_name = "demo-dev-deploy-group"
  service_role_arn      = aws_iam_role.code-deploy.arn

  ec2_tag_set {
    ec2_tag_filter {
      key   = "Env"
      type  = "KEY_AND_VALUE"
      value = "Dev-CICD"
    }
  }

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }
}

resource "aws_codedeploy_deployment_group" "demo-prod-deploy-group" {
  app_name              = aws_codedeploy_app.demo-deploy.name
  deployment_group_name = "demo-prod-deploy-group"
  service_role_arn      = aws_iam_role.code-deploy.arn

  ec2_tag_set {
    ec2_tag_filter {
      key   = "Env"
      type  = "KEY_AND_VALUE"
      value = "Prod-CICD"
    }
  }

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }
}

//Code PipeLine
resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket        = "demo-jana-test-pipeline-bucket"
  acl           = "private"
  force_destroy = true
}

resource "aws_codepipeline" "codepipeline" {
  name     = "demo-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.codepipeline_bucket.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        RepositoryName = aws_codecommit_repository.repo.repository_name
        BranchName     = "main"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.code-build.name
      }
    }
  }

  stage {
    name = "Deploy-Dev"

    action {
      name            = "Deploy-Dev-EC2"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeploy"
      input_artifacts = ["build_output"]
      version         = "1"

      configuration = {
        ApplicationName     = aws_codedeploy_app.demo-deploy.name
        DeploymentGroupName = aws_codedeploy_deployment_group.demo-dev-deploy-group.deployment_group_name
      }
    }
  }

  stage {
    name = "Manual-Approval"

    action {
      name            = "Approve-Prod-Deployment"
      category        = "Approval"
      owner           = "AWS"
      provider        = "Manual"
      version         = "1"

      configuration = {
        CustomData      = "Prod Deployment Approval Request"
        NotificationArn = aws_sns_topic.manual-approval.arn
      }
    }
  }

  stage {
    name = "Deploy-Prod"

    action {
      name            = "Deploy-Prod-EC2"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeploy"
      input_artifacts = ["build_output"]
      version         = "1"

      configuration = {
        ApplicationName     = aws_codedeploy_app.demo-deploy.name
        DeploymentGroupName = aws_codedeploy_deployment_group.demo-prod-deploy-group.deployment_group_name
      }
    }
  }
}