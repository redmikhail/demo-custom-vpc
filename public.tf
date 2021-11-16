
/*
  Create bastion host to be able to access EC2 instances in private subnet

  Note: script relies on having ssh key-pair created. If it has been done use command to create keypar:
  aws ec2 create-key-pair --key-name illumio_demo_kp --query "KeyMaterial"  --output text > illumio_demo_kp.pem
  
*/
resource "aws_security_group" "bastion_server" {
  name        = "${var.PROJECT_NAME}-bastion-sg"
  description = "Security group for bastion server"
  vpc_id      = "${aws_vpc.illumio_demo_vpc.id}"

  ingress {
    description      = "ssh to bastion server"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.PROJECT_NAME}-bastion-sg"
    Project = "${var.PROJECT_NAME}"
  }
}

data "aws_security_group" "selected" {
  filter {
    name = "group-name"
    values = ["${var.PROJECT_NAME}-bastion-sg"]
  }
  depends_on = [
    aws_security_group.bastion_server
  ]
}

resource "aws_instance" "bastion_server" {
  ami           = "ami-01e36b7901e884a10"
  instance_type = "t3.large"
  availability_zone = "${var.aws_region}a"
  key_name = "${var.PROJECT_NAME}_kp"
  subnet_id = aws_subnet.us-east-2a-public.id
  vpc_security_group_ids = [data.aws_security_group.selected.id]
  root_block_device  {
    volume_size = "50"
  }

  tags = {
    Name = "${var.PROJECT_NAME}_bastion"
    Project = "${var.PROJECT_NAME}"
  }
}

resource "aws_eip" "lb" {
  instance = aws_instance.bastion_server.id
  vpc      = true
}

/*add additional disk device if needed for data (Example - DB) */
/* 
resource "aws_volume_attachment" "bastion_server" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.bastion_server.id
  instance_id = aws_instance.bastion_server.id
}

resource "aws_ebs_volume" "bastion_server" {
  availability_zone = "${var.aws_region}a"
  size              = 50

  tags = {
    Name = "bastion_server-vol-att"
    Project = "${var.PROJECT_NAME}"
  }
} */