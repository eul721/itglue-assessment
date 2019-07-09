resource "aws_lb" "public-to-ecs-alb" {
    name = "public-to-private-alb"
    internal = false
    load_balancer_type = "application"
    security_groups = [aws_security_group.public-sg.id]
    subnets = [
        aws_subnet.public-zone1.id,
        aws_subnet.public-zone2.id
    ]
    tags = local.common_aws_tags 

}



resource "aws_lb_target_group" "app-tg" {
    name = "${var.project-name}-tg"
    port = 8080
    protocol = "HTTP"
    target_type = "ip"
    vpc_id = var.vpc-id
    health_check {
        path = "/upload"
    }
}
resource "aws_lb_listener" "public-to-ecs-alb-app-tg" {
    load_balancer_arn = aws_lb.public-to-ecs-alb.arn
    port = "80"
    protocol = "HTTP"

    default_action {
        type = "forward"
        target_group_arn = aws_lb_target_group.app-tg.arn
    }
}
# resource "aws_lb_target_group_attachment" "public-to-ecs-alb-app-tg" {
#     target_group_arn = aws_lb_target_group.app-tg.arn
#     target_
# }