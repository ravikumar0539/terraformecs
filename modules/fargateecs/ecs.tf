resource "aws_ecs_cluster" "main"{
    name="appcluster"
}
data "template_file" "myapp"{
    template = "${file("./templates/image.json.tpl")}"
    vars {
        image= "${var.image}"
        fargate_cpu=  "${var.fargate_cpu}"
        fargate_memory= "${var.fargate_memory}"
        aws_region = "${var.aws_region}"
        appport = "${var.appport}"
    }
}

resource "aws_ecs_task_definition" "main" {
    family = "firsttask"
    execution_role_arn  = "${aws_iam_role.ecs_task_execution_role.arn}"
    network_mode = "awsvpc"
    requires_compatibilities = ["fargate"]
    cpu = "${var.fargate_cpu}"
    memory = "${var.fargate_memory}"
    container_definitions = "${data.template_file.myapp.rendered}"
}

resource "aws_ecs_service" "main"{
    name = "firstservice"
    cluster = "${aws_ecs_cluster.main.id}"
    task_definition = "${aws_ecs_task_definition.main.id}"
    desired_count = "${var.appcount}"
    launch_type = "fargate"
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