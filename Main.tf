provider "aws" {
   region = var.aws-region
}
resource "aws_vpc" "main" {
    cidr_block = var.vpc-cidr
    enable_dns_hostnames = true
    enable_dns_support = true
    tags = {
       Name = "Main_VPC"
    } 
}
resource "aws_internet_gateway" "IGW" {
    vpc_id = aws_vpc.main.id
    tags ={
        Name = "IGW"
    }
}
# Public Subnet configuation 
resource "aws_subnet" "public_subnet" {
    vpc_id = aws_vpc.main.id
    count = 2 
    cidr_block = cidrsubnet(var.vpc-cidr, 8, count.index)
    availability_zone = element(["ap-south-1a", "ap-south-1b"],count.index)
    map_public_ip_on_launch = true

    tags = {
        Name = "Public_Subnet_${count.index}"
    }
}
# Private Subnet configuration
  resource "aws_subnet" "Private_subnet" {
    vpc_id = aws_vpc.main.id
    count = 2 
    cidr_block = cidrsubnet(var.vpc-cidr, 8, count.index + 10) 
    availability_zone = element(["ap-south-1a", "ap-south-1b"],count.index)
    map_public_ip_on_launch = false

    tags = {
        Name = "Private_Subnet_${count.index}"
    }
}
#  EIP for NAT Gateway
resource "aws_eip" "nat_eip" {
    domain = "vpc"
}

# NAT Gateway Configuration
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
subnet_id = aws_subnet.public_subnet[0].id  
}

#  Route Table for Public Subnet 
 resource "aws_route_table" "public_rt" {
   vpc_id = aws_vpc.main.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.IGW.id
    }
 }

 # Route table for private subnet
    resource "aws_route_table" "private_rt" {
          vpc_id = aws_vpc.main.id 

          route {
            cidr_block = "0.0.0.0/0" 
            nat_gateway_id = aws_nat_gateway.nat_gw.id
          }  
    }
    # Route  table asscociation with public subnet 
    resource "aws_route_table_association" "public_subnet_assoc" {
         count =  2
         subnet_id = aws_subnet.public_subnet[count.index].id
         route_table_id = aws_route_table.public_rt.id   
    }
    # Route  table asscociation with private subnet
    resource "aws_route_table_association" "private_subnet_assoc" {
        count = 2
        subnet_id = aws_subnet.Private_subnet[count.index].id
        route_table_id = aws_route_table.private_rt.id      
    }

  # Security Group Configuration
   resource "aws_security_group" "ALB_SG" {
       vpc_id = aws_vpc.main.id
       
     ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
     }
      egress {
        from_port = 0
        to_port = 0 
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
      }
   }  
     #  Target Group Configuration 
        resource "aws_lb_target_group" "target_group" {
            name = "app-target-group"
            port = 80
            protocol = "HTTP"
            vpc_id = aws_vpc.main.id 

           health_check {
             path = "/"
             interval = 30 
             timeout = 5
             healthy_threshold = 2 
             unhealthy_threshold = 2
             matcher = "200"
           }       
        }
          # Application Load Balancer Configuration 
     resource "aws_lb" "ALB" {
        name = "app-load-balancer"
        internal = false 
        load_balancer_type = "application"
        security_groups = [aws_security_group.ALB_SG.id]
        subnets = [
            aws_subnet.public_subnet[0].id,
            aws_subnet.public_subnet[1].id
        ]
         tags = {
            Name = "ALB"
         }
           }
 #   Listener Configuration for ALB
        resource "aws_lb_listener" "listener" {
          load_balancer_arn = aws_lb.ALB.arn
          port = 80
          protocol = "HTTP"
          default_action {
            type = "forward"
            target_group_arn = aws_lb_target_group.target_group.arn
          }
        }
 #Lsitening to 3000 for Grafana
 #resource "aws_lb_listener" "ter_listener" {
  #load_balancer_arn = aws_lb.ALB.arn
   #port = 3000
    #protocol = "HTTP"
    #default_action {
     #type = "forward"
      # target_group_arn =  aws_lb_target_group.grafana-tg.arn
    
# target group attachment for EC2 instances
resource "aws_autoscaling_group" "auto-SG" {
    name = "AutoScaling-Group"
    min_size = 1
    max_size = 3
    desired_capacity = 1
    vpc_zone_identifier =[
        aws_subnet.Private_subnet[0].id,
        aws_subnet.Private_subnet[1].id
    ]
    target_group_arns = [
        aws_lb_target_group.target_group.arn,
        aws_lb_target_group.grafana-tg.arn
    ]
 health_check_type = "ELB"
 health_check_grace_period = 300

 launch_template {
   id = aws_launch_template.Private-Server-Template.id
   version = "$Latest"
 }
}
