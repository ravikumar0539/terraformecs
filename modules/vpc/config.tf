variable "vpc_cidr" {
  default = "172.37.0.0/16"
}

variable "environment"{
    default ="dev"
}

variable "counting" {
    default = 2
}
variable "appport" {
    default = 80
  
}
variable "outport"{
    default = 443
}
