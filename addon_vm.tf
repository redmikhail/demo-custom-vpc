resource "aws_instance" "illumio_vm3" {
  ami           = "ami-0a509b3c2a4d05b3f"
  instance_type = "m5.large"
  availability_zone = "${var.aws_region}a"
  key_name = "${var.PROJECT_NAME}_kp"
  subnet_id = aws_subnet.us-east-2a-private.id
  vpc_security_group_ids = [data.aws_security_group.selected_vm.id]
  root_block_device  {
    volume_size = "50"
  }

  tags = {
    Name = "${var.PROJECT_NAME}_illumio_vm3"
    Project = "${var.PROJECT_NAME}"
  }
}

resource "aws_instance" "illumio_vm4" {
  ami           = "ami-0a509b3c2a4d05b3f"
  instance_type = "m5.large"
  availability_zone = "${var.aws_region}a"
  key_name = "${var.PROJECT_NAME}_kp"
  subnet_id = aws_subnet.us-east-2a-private.id
  vpc_security_group_ids = [data.aws_security_group.selected_vm.id]
  root_block_device  {
    volume_size = "50"
  }

  tags = {
    Name = "${var.PROJECT_NAME}_illumio_vm4"
    Project = "${var.PROJECT_NAME}"
  }
}
