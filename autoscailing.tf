# Create a launch template
resource "aws_launch_template" "launcht-lexi" {
  name          = "example-launch-template"
  image_id      = "ami-04219acffee857817"
  instance_type = "t2.micro"     
  network_interfaces {
    device_index                  = 0
    subnet_id                     = aws_subnet.public_subnet.id
    security_groups               = [aws_security_group.public_sg_lexi.id]
    associate_public_ip_address   = true
  }
}

# Create an autoscaling group
resource "aws_autoscaling_group" "asg-terra-lexi" {
  name                      = "example-autoscaling-group-terra"
  min_size                  = 1
  max_size                  = 2
  desired_capacity          = 1
  health_check_grace_period = 300
  launch_template {
    id      = aws_launch_template.launcht-lexi.id
    version = "$Latest"
  }

  vpc_zone_identifier = [
    aws_subnet.public_subnet.id,
    aws_subnet.private_subnet.id,
  ]

  target_group_arns = [
    aws_lb_target_group.tg-terra-lexi.arn,
  ]
  
}
# Create a load balancer
resource "aws_lb" "lb-terra-lexi" {
  name               = "example-load-balancer-terra-lexi"
  load_balancer_type = "application"

  subnets = [
    aws_subnet.public_subnet.id,
    aws_subnet.public_subnet-b.id,
  ]
}

# Create a listener for HTTP to HTTPS redirect
resource "aws_lb_listener" "example-ls" {
  load_balancer_arn = aws_lb.lb-terra-lexi.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# Create a target group
resource "aws_lb_target_group" "tg-terra-lexi" {
  name        = "example-target-group-terra-lexi"
  port        = 443
  protocol    = "HTTPS"
  vpc_id      = aws_vpc.terra-lexi.id
  target_type = "instance"
}

# Create an EC2 instance
resource "aws_instance" "example-instance" {
  ami           = aws_launch_template.launcht-lexi.image_id
  instance_type = aws_launch_template.launcht-lexi.instance_type
  subnet_id     = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.public_sg_lexi.id]

 
}

