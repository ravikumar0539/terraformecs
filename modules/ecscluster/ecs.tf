resource "aws_ecs_cluster" "main"{
    name="${var.clustername}"
}

data "template_file" "myapp"{
    template = "${file("./template/image.json.tpl")}"
    vars {
        image1= "${var.image1}"
        image2 = "${var.image2}"
        cpu=  "${var.cpu}"
        memory= "${var.memory}"
        aws_region = "${var.aws_region}"
        appport = "${var.appport}"
    }
}
resource "aws_ecs_task_definition" "main" {
    family = "firsttask"
    #ARN of IAM role that allows your Amazon ECS container task to make calls to other AWS services.
    task_role_arn = "${aws_iam_role.ecs-service-role.arn}"
    #ARN of the task execution role that the Amazon ECS container agent and the Docker daemon can assume.
    execution_role_arn  = "${aws_iam_role.ecs-service-role.arn}" #
    network_mode = "awsvpc"
    requires_compatibilities = ["EC2"]
    cpu = "${var.taskcpu}"
    memory = "${var.taskmemory}"
    container_definitions = "${data.template_file.myapp.rendered}"
}


resource "aws_ecs_service" "main"{
    name = "firstservice"
    cluster = "${aws_ecs_cluster.main.id}"
    iam_role = "${aws_iam_role.ecs-service-role.arn}"
    task_definition = "${aws_ecs_task_definition.main.family}:${max("${aws_ecs_task_definition.main.revision}")}",
    desired_count = "${var.appcount}"
    launch_type = "ec2"
    network_configuration {
        security_groups = ["${aws_security_group.ecs_tasks.id}"]
        assign_public_ip = true
        subnets          = "${var.privatesubnet}"
    }
    load_balancer {
    target_group_arn = "${aws_alb_target_group.main.id}"
    container_name   = "firstapp"
    container_port   = "${var.appport}"
  }
  depends_on = ["aws_alb_listener.front_end", "aws_iam_role_policy_attachment.ecs_task_execution_role"]

}