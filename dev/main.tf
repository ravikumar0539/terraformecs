
variable "env" {
}
variable "vpc" {
}
variable "countin" {
}

variable "region" {
}


provider "aws" {
    access_key = ""
    secret_key = ""
    region = "${var.region}"
}

module "myvpc" {
  source = "../modules/vpc"
  vpc_cidr= "${var.vpc}"
  environment="${var.env}"
  counting="${var.countin}"
  
}



resource "local_file" "foo" {
    content  = "security_groups: ${module.myvpc.security}\nelb: ${module.loadbalancer.elbname}\nalbname: ${module.loadbalancer.albname}\nregion: ${var.region}"
    filename = "${path.module}/packer/group_vars/all"
}

module "ecsfargate"{
  source = "../modules/fargateecs"
  vpc_id= "${module.myvpc.vpc_id}"
  publicsubnet= "${module.myvpc.publicsubnets}"
  privatesubnet = "${module.myvpc.privatesubnet}"
}
module "ecscluster"{
  source = "../modules/ecscluster"
  vpc_id= "${module.myvpc.vpc_id}"
  publicsubnet= "${module.myvpc.publicsubnets}"
  privatesubnet = "${module.myvpc.privatesubnet}"


}

