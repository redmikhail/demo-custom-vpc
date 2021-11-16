/*
  Will create Custom vpc with public and private subnets using AWS "Corporate VPC" demo scenario  
*/
resource "aws_vpc" "illumio_demo_vpc" {
    cidr_block = "${var.vpc_cidr}"
    enable_dns_hostnames = true
    tags = {
        Name = "illumio_demo_vpc"
        Project = "${var.PROJECT_NAME}"
    }
}

resource "aws_internet_gateway" "igw" {
    vpc_id = "${aws_vpc.illumio_demo_vpc.id}"
    tags = {
        Project = "${var.PROJECT_NAME}" 
    }
}

/*
  NAT Instance
*/
resource "aws_security_group" "nat" {
    name = "vpc_nat"
    description = "Allow traffic to pass from the private subnet to the internet"

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["${var.private_subnet_cidr}"]
    }
    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["${var.private_subnet_cidr}"]
    }
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 1024
        to_port = 65535
        protocol = "tcp"
        cidr_blocks = [var.private_subnet_cidr]
    }

    egress {
        from_port = 0
        to_port = 65535
        protocol = "tcp"
        cidr_blocks = [var.private_subnet_cidr]
    }

    vpc_id = "${aws_vpc.illumio_demo_vpc.id}"

    tags = {
        Name = "${var.PROJECT_NAME}_sg"
        Project = "${var.PROJECT_NAME}"
    }
}



resource "aws_eip" "nat_eip" {
    vpc   = true
    depends_on = [aws_internet_gateway.igw]
    tags = {
        Name = "${var.PROJECT_NAME}_nat_eip"
        Project = "${var.PROJECT_NAME}"
    }
}

resource "aws_nat_gateway" "nat" {
    allocation_id = aws_eip.nat_eip.id
    subnet_id     = "${aws_subnet.us-east-2a-public.id}"
    tags = {
        Project = "${var.PROJECT_NAME}"
    }
}

/*
  Public Subnet
*/
resource "aws_subnet" "us-east-2a-public" {
    vpc_id = "${aws_vpc.illumio_demo_vpc.id}"

    cidr_block = "${var.public_subnet_cidr}"
    availability_zone = "us-east-2a"

    tags = {
        Name = "Public Subnet"
        Project = "${var.PROJECT_NAME}"
    }
    # This is very important - prevents deleting openshift tags added to subnet on terraform update 
    lifecycle {
        ignore_changes = [tags]
    }
}

resource "aws_route_table" "us-east-2a-public" {
    vpc_id = "${aws_vpc.illumio_demo_vpc.id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.igw.id}"
    }

    tags = {
        Name = "Public Subnet Route Table"
        Project = "${var.PROJECT_NAME}"
    }
}

resource "aws_route_table_association" "us-east-2a-public" {
    subnet_id = "${aws_subnet.us-east-2a-public.id}"
    route_table_id = "${aws_route_table.us-east-2a-public.id}"
}

/*
  Private Subnet
*/
resource "aws_subnet" "us-east-2a-private" {
    vpc_id = "${aws_vpc.illumio_demo_vpc.id}"

    cidr_block = "${var.private_subnet_cidr}"
    availability_zone = "us-east-2a"

    tags = {
        Name = "Private Subnet"
        Project = "${var.PROJECT_NAME}"
    }
}

resource "aws_route_table" "us-east-2a-private" {
    vpc_id = "${aws_vpc.illumio_demo_vpc.id}"

    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = "${aws_nat_gateway.nat.id}"
    }

    tags = {
        Name = "Private Subnet Route Table"
        Project = "${var.PROJECT_NAME}"
    }
    depends_on = [aws_nat_gateway.nat]
}

resource "aws_route_table_association" "us-east-2a-private" {
    subnet_id = "${aws_subnet.us-east-2a-private.id}"
    route_table_id = "${aws_route_table.us-east-2a-private.id}"
}
