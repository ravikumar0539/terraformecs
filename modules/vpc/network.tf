resource "aws_vpc" "devvpc" {
    cidr_block = "${var.vpc_cidr}"
    enable_dns_hostnames="true"
    enable_dns_support="true"
    tags = {
         Name = "${var.environment}"
    }
}

data "aws_availability_zones" "available" {}
resource "aws_subnet" "publicsubnet"{
    count = "${var.counting}"
    map_public_ip_on_launch = true
    vpc_id = "${aws_vpc.devvpc.id}"
    cidr_block = "${cidrsubnet(aws_vpc.devvpc.cidr_block, 8, count.index)}"
    availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
    tags = {
        Name = "publicsubnet-${count.index}"
    }
}

resource "aws_subnet" "privatesubnet" {
    count = "${var.counting}"
    vpc_id = "${aws_vpc.devvpc.id}"
    cidr_block = "${cidrsubnet(aws_vpc.devvpc.cidr_block, 8, "${var.counting}" + count.index)}"
    availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
    tags= {
         Name = "privatesubnet-${count.index + "${var.counting}"}"
    }
}

#Internet gateway for public subnet
resource "aws_internet_gateway" "devgateway"{
    vpc_id = "${aws_vpc.devvpc.id}"
}
    
#Route public subnet traffic through IGW
resource "aws_route_table" "igw_table" {
    vpc_id = "${aws_vpc.devvpc.id}"
    count = "${var.counting}"
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.devgateway.id}"
        }

}

#Create a NAT gateway for each private subnet internet connectivity
resource "aws_eip" "natgw"{
    count = "${var.counting}"
    vpc = true
    depends_on = ["aws_internet_gateway.devgateway"]
    
    tags = {
        "Name " = "natgateway-${var.environment}-${count.index}"
}
}

resource "aws_nat_gateway" "devinternal"{
    count = "${var.counting}"
    allocation_id = "${element(aws_eip.natgw.*.id, count.index)}"
    subnet_id = "${element(aws_subnet.publicsubnet.*.id, count.index)}"
}

# Create a new route table for the private subnets, make it route non-local traffic through the NAT gateway to the internet

resource "aws_route_table" "nat_table" {
    count = "${var.counting}"
    vpc_id = "${aws_vpc.devvpc.id}"
    route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${element(aws_nat_gateway.devinternal.*.id, count.index)}"
  }
}
# Explicitly associate the newly created route tables to the private subnets (so they don't default to the main route table)
resource "aws_route_table_association" "privateroute" {
  count = "${var.counting}"
  subnet_id      = "${element(aws_subnet.privatesubnet.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.nat_table.*.id, count.index)}"
}
resource "aws_route_table_association" "publicroute" {
  count = "${var.counting}"
  subnet_id      = "${element(aws_subnet.publicsubnet.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.igw_table.*.id, count.index)}"
}

resource "aws_security_group" "main" {
    name = "main-${var.environment}"
    vpc_id = "${aws_vpc.devvpc.id}"
    ingress {
    protocol    = "tcp"
    from_port   = "${var.appport}"
    to_port     = "${var.appport}"
    cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
    protocol    = "tcp"
    from_port   = "${var.outport}"
    to_port     = "${var.outport}"
    cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol ="-1"
        cidr_blocks = ["0.0.0.0/0"]

     }

}
output "vpc_id"{
    value = "${aws_vpc.devvpc.id}"
}
output "publicsubnets"{
    value = "${aws_subnet.publicsubnet.*.id}"
}
output "security"{
    value = "${aws_security_group.main.id}"
}
output "privatesubnet"{
    value = "${aws_subnet.privatesubnet.*.id}"
}