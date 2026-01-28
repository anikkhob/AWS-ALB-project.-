resource "aws_lb_target_group" "grafana-tg" {
    name =  "grafana-tg"
    port = 3000
    protocol = "HTTP"
    vpc_id = aws_vpc.main.id
   target_type = "instance"

   health_check {
     path = "/login"
     protocol = "HTTP"
     port = 3000
     healthy_threshold = 2
     unhealthy_threshold = 2
     timeout = 5
     interval = 30
     matcher = "200-399"
 }

}