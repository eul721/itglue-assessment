output "repo_url" {
    value = aws_ecr_repository.ecr-repo.repository_url
}

output "lb_dns" {
    value = aws_lb.public-to-ecs-alb.dns_name
}

output "ecs_cluster_name" {
    value = aws_ecs_cluster.ecs-cluster.name
}

output "ecs_service_name" {
    value = aws_ecs_service.app-ecs-service.name
}

output "s3_bucket_name" {
    value = aws_s3_bucket.dest-bucket.id
}
