variable "clustername"{
    default = "mycluster"
}

variable "image1" {
  default = "wordpress"
}

variable "cpu" {
    default= "30"
}
variable "memory" {
  default = "400"
}

variable "keypair" {
  default = "testing"
}
variable "aws_ami" {
    type = "map"
    default {
        us-east-1= "ami-fad25980"
        us-west-2= "ami-fad259890"
    }
  
}
variable "publicsubnet" {
  
}
variable "vpc_id" {
  
}


variable "instanctype" {
  default = "t2.xlarge"
}


variable "aws_region" {
  default ="us-east-1"
}
variable "taskcpu" {
  default = "60"
}
variable "taskmemory" {
  defulat = "900"
}

variable "appcount" {
  default ="2"
}

variable "health_check_path" {
  default = "/"
}


variable "appport" {
  default = "8080"
}

variable "image2" {
  default = "mysql"
}
variable "privatesubnet" {
  
}
