resource "aws_launch_configuration" "ecs-launch-configuration" {
    name                        = "ecs-launch-configuration"
    image_id                    = "${lookup(var.aws_ami,var.aws_region)}"
    instance_type               = "${var.instanctype}"
    iam_instance_profile        = "${aws_iam_instance_profile.ecs-instance-profile.id}"

    root_block_device {
      volume_type = "standard"
      volume_size = 100
      delete_on_termination = true
    }

    lifecycle {
      create_before_destroy = true
    }

    security_groups             = ["${aws_security_group.lb.id}"]
    associate_public_ip_address = "true"
    key_name                    = "${var.keypair}"
    user_data              = "${data.template_file.user_data.rendered}"
}

data "template_file" "user_data" {
  template = "${file("./template/userdata.tpl")}"
  vars{
      clustername = "${aws_ecs_cluster.main.name}"
  }
}


resource "aws_autoscaling_group" "ecs-autoscaling-group" {
    name                        = "ecs-autoscaling-group"
    max_size                    = 2
    min_size                    = 1
    desired_capacity            = 1
    vpc_zone_identifier         = "${var.privatesubnet}"
    launch_configuration        = "${aws_launch_configuration.ecs-launch-configuration.name}"
    target_group_arns           = "${aws_alb_target_group.main.id}"
  }