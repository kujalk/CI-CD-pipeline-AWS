
output "Dev-EC2-IP" {
  value = aws_instance.Dev.public_ip
}

output "Prod-EC2-IP" {
  value = aws_instance.Prod.public_ip
}


output "RepoURL" {
  value = aws_codecommit_repository.repo.clone_url_http
}