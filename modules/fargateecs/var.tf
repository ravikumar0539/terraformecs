variable "aws_region"{
 default ="us-east=-1"
}
variable "ecs_task_execution_role_name"{
    description = "ECS execution role"
    default = "ecstaskrole"
}
variable "vpc_id" {
  
}
variable "privatesubnet" {
    type = "list"
  
}


variable "image"{
    default = "tomcat:8"
}
variable "appport" {
  default = 8080
}
varable "appcount"{
    default =2
}
variable "health_check_path" {
  default= "/"
}
variable "fargate_cpu" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
  default     = "1024"
}

variable "fargate_memory" {
  description = "Fargate instance memory to provision (in MiB)"
  default     = "2048"
}
variable "publicsubnet" {
  
}
