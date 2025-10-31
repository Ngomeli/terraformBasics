# Security group for ALB (allow 80/443 from anywhere)
resource "aws_security_group" "alb_sg" {
  name   = "${var.environment}-alb-sg"
  vpc_id = var.vpc_id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

}

# Security group for app instances (allow from ALB only and SSH from your IP optionally)
resource "aws_security_group" "app_sg" {
  name   = "${var.environment}-app-sg"
  vpc_id = var.vpc_id
  ingress {
    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_cidr]   # set to your IP
  }
  egress {
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

}

# ALB
resource "aws_lb" "alb" {
  name               = "${var.environment}-alb"
  load_balancer_type = "application"
  subnets            = var.public_subnets
  security_groups    = [aws_security_group.alb_sg.id]
  tags = { Environment = var.environment }
}

resource "aws_lb_target_group" "tg" {
  name     = "${var.environment}-tg"
  port     = var.app_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  health_check {
    path = var.health_check_path
    matcher = "200-399"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

# Launch Template
resource "aws_launch_template" "lt" {
  name_prefix   = "${var.environment}-lt-"
  image_id      = var.app_ami
  instance_type = var.instance_type
  key_name      = var.ssh_key_name

  iam_instance_profile {
    name = var.instance_profile_name
  }

  network_interfaces {
    security_groups = [aws_security_group.app_sg.id]
    associate_public_ip_address = false
  }

  user_data = base64encode(var.user_data) # optional
  tag_specifications {
    resource_type = "instance"
    tags = { Name = "${var.environment}-app" }
  }
}

# Auto Scaling Group (using Launch Template)
resource "aws_autoscaling_group" "asg" {
  desired_capacity     = var.desired_capacity
  max_size             = var.max_size
  min_size             = var.min_size
  vpc_zone_identifier  = var.private_subnets
  launch_template {
    id      = aws_launch_template.lt.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.tg.arn]

  tag {
    key                 = "Name"
    value               = "${var.environment}-asg"
    propagate_at_launch = true
  }
}
