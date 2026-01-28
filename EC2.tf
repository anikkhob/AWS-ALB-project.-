# Security Group for EC2 Instances 
 resource "aws_security_group" "EC2_SG" {
   vpc_id = aws_vpc.main.id

# SHH access rule 
   ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
   }
   # HTTP access rule 
    ingress {
      from_port = 80
      to_port = 80
      protocol = "tcp"
      security_groups = [aws_security_group.ALB_SG.id]
    }
   # Grafana access rule
     ingress {
        from_port = 3000
        to_port = 3000
        protocol = "tcp"
        security_groups = [aws_security_group.ALB_SG.id]
     }
    
    egress {
      from_port = 0
      to_port = 0 
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]     
 }
  tags = {
    Name = "EC2_SG"
  }
 }

# EC2 Instance Configuration
         resource "aws_launch_template" "Private-Server-Template" {
            name_prefix = "Private-Server-Template"
            image_id = "ami-019715e0d74f695be" # Ubuntu 22.04 LTS AMI ID for ap-south-1
            instance_type = "t3.micro"
            vpc_security_group_ids = [aws_security_group.EC2_SG.id]
           user_data =  base64encode(<<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y apache2 software-properties-common
              wget -q -O - https://packages.grafana.com/gpg.key | apt-key add -
              echo "deb https://packages.grafana.com/oss/deb stable main" | tee -a /etc/apt/sources.list.d/grafana.list
              apt-get update -y
              apt-get install -y grafana
              systemctl start grafana-server
              systemctl enable grafana-server
              systemctl start apache2
              systemctl enable apache2
              echo "<h1>Welcome to the Private EC2 Instance Auto Scaling</h1>" > /var/www/html/index.html
              EOF
            )
            tag_specifications {
              resource_type = "instance"
              tags = {
                Name = "Private-Server-Template"
              }
            }      
         }

   # Endpoint to access VPC resources
resource "aws_ec2_instance_connect_endpoint" "Endpoint-EC2" {
    subnet_id = aws_subnet.Private_subnet[1].id
    security_group_ids = [
       aws_security_group.EC2_SG.id

    ]
  
  tags = {
    Name = "Endpoint-EC2"
  }
}

