//Role for CodeBuild
resource "aws_iam_role" "CodeBuild_Role" {
  name = "DemoCodeBuild_Role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "CodeBuild_Policy" {
  role   = aws_iam_role.CodeBuild_Role.name
  name   = "codebuild_policy"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "codebuild:*",
        "codecommit:*",
        "codedeploy:*",
        "ec2:*",
        "sns:*",
        "s3:*"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

//Role for CodeDeploy
resource "aws_iam_role" "code-deploy" {
  name = "DemoCodeDeploy_Role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "codedeploy.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "AWSCodeDeployRole" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
  role       = aws_iam_role.code-deploy.name
}

//Code PipeLine
resource "aws_iam_role" "codepipeline_role" {
  name = "DemoCodePipeLine_Role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name = "codepipeline_policy"
  role = aws_iam_role.codepipeline_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "codebuild:*",
        "codecommit:*",
        "codedeploy:*",
        "ec2:*",
        "sns:*",
        "s3:*"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

//For EC2
resource "aws_iam_role" "ec2-demo-cicd" {
  name = "DemoEC2_Artifact"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ec2-policy-attach" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforAWSCodeDeploy"
  role       = aws_iam_role.ec2-demo-cicd.name
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2_demo_profile"
  role = aws_iam_role.ec2-demo-cicd.name
}

