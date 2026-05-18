output "repository_name" {

  value = aws_codecommit_repository.app_repo.repository_name

}

output "clone_url_http" {

  value = aws_codecommit_repository.app_repo.clone_url_http

}