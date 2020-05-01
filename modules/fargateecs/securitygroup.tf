resource "aws_security_group" "lb" {
  name        = "ecslbsecuritygroup"
  vpc_id      =  "${var.vpc_id}"

  ingress {
    protocol    = "tcp"
    from_port   = "${var.appport}"
    to_port     = "${var.appport}"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Traffic to the ECS cluster should only come from the ALB
resource "aws_security_group" "ecs_tasks" {
  name        = "ecstaskssecuritygroup"
  
  vpc_id      = "${var.vpc_id}"

  ingress {
    protocol        = "tcp"
    from_port       ="${var.appport}"
    to_port         = "${var.appport}"
    security_groups = ["${aws_security_group.lb.id}"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}