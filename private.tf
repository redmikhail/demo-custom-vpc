/*
  Create two standalone RHEL 7.9 VM's in the custom VPC 
*/

# Allow all traffic on private subnet to reach standalone vms 
resource "aws_security_group" "standalone_vms" {
  name        = "${var.PROJECT_NAME}-standalone-vms-sg"
  description = "Security group for standalone vms"
  vpc_id      = "${aws_vpc.illumio_demo_vpc.id}"

  ingress {
    description      = "incoming traffic to standalone vms"
    from_port        = 0
    to_port          = 0
    protocol         = -1
    cidr_blocks      = ["${var.private_subnet_cidr}"]
  }
  ingress {
    description      = "ssh from bastion server"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    security_groups = [data.aws_security_group.selected.id]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = -1
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.PROJECT_NAME}-standalone-vms-sg"
    Project = "${var.PROJECT_NAME}"
  }
}

data "aws_security_group" "selected_vm" {
  filter {
    name = "group-name"
    values = ["${var.PROJECT_NAME}-standalone-vms-sg"]
  }
  depends_on = [
    aws_security_group.standalone_vms
  ]
}

#  Create first RHEL 7.9 and extend default root disk to 100 GB

resource "aws_instance" "illumio_vm1" {
  ami           = "ami-0a509b3c2a4d05b3f"
  instance_type = "m5.large"
  availability_zone = "${var.aws_region}a"
  key_name = "${var.PROJECT_NAME}_kp"
  subnet_id = aws_subnet.us-east-2a-private.id
  vpc_security_group_ids = [data.aws_security_group.selected_vm.id]
  root_block_device  {
    volume_size = "100"
  }

  tags = {
    Name = "${var.PROJECT_NAME}_illumio_vm1"
    Project = "${var.PROJECT_NAME}"
  }
}

#  Add additional disk device for vm1 if needed for data (Example - DB) 

/*
resource "aws_volume_attachment" "illumio_vm1" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.illumio_vm1.id
  instance_id = aws_instance.illumio_vm1.id
}

resource "aws_ebs_volume" "illumio_vm1" {
  availability_zone = "${var.aws_region}a"
  size              = 100

  tags = {
    Name = "illumio_vm1-vol"
    Project = "${var.PROJECT_NAME}"
  }
}
*/

#  Create second RHEL 7.9 and extend default root disk to 100 GB

resource "aws_instance" "illumio_vm2" {
  ami           = "ami-0a509b3c2a4d05b3f"
  instance_type = "m5.large"
  availability_zone = "${var.aws_region}a"
  key_name = "${var.PROJECT_NAME}_kp"
  subnet_id = aws_subnet.us-east-2a-private.id
  vpc_security_group_ids = [data.aws_security_group.selected_vm.id]

  tags = {
    Name = "${var.PROJECT_NAME}_illumio_vm2"
    Project = "${var.PROJECT_NAME}"
  }
}

# Add additional disk device for vm2 if needed for data (Example - DB)

/*
resource "aws_volume_attachment" "illumio_vm2" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.illumio_vm2.id
  instance_id = aws_instance.illumio_vm2.id
}

resource "aws_ebs_volume" "illumio_vm2" {
  availability_zone = "${var.aws_region}a"
  size              = 100

  tags = {
    Name = "illumio_vm2-vol"
    Project = "${var.PROJECT_NAME}"
  }
}
*/