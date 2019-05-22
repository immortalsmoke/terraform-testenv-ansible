#######
# VPC #
#######

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  #private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  tags = "${merge(
    var.common_tags,
    map(
      "Name", "ansible-test-vpc"
    )
  )}"
}






###################
# Security Groups #
###################



resource "aws_security_group" "temp_ssh_inbound" {
  name        = "SSH Inbound"
  description = "Allow SSH"
  vpc_id      = "${module.vpc.vpc_id}"

  tags = "${merge(
    var.common_tags,
    map(
      "Name", "sg-temp-ssh-inbound"
    )
  )}"
}
resource "aws_security_group_rule" "temp_ssh_inbound_from_world" {
  type            = "ingress"
  from_port       = 22
  to_port         = 22
  protocol        = "tcp"
  cidr_blocks     = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.temp_ssh_inbound.id}"
}

resource "aws_security_group_rule" "allow_all_outbound" {
  type            = "egress"
  from_port       = 0
  to_port         = 65535
  protocol        = "tcp"
  cidr_blocks     = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.temp_ssh_inbound.id}"
}


#####################################
# EC2 Instances and Associated Data #
#####################################

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*"]
  }

  filter {
		name   = "architecture"
		values = ["x86_64"]
	}

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] #Canonical
}



data "aws_ami" "centos" {
  most_recent = true

  filter {
    name   = "name"
    values = ["CentOS Linux 7 x86_64 HVM EBS*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["410186602215"]
}








resource "tls_private_key" "ansible-test-keys" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ansible-test-key-pair" {
  key_name   = "ansible-test-key-pair"
  public_key = "${tls_private_key.ansible-test-keys.public_key_openssh}"
}
















resource "aws_instance" "ansible-test-ubuntu-001" {
  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "t3.nano"
  count					= 3
  user_data     = "${path.cwd}/userdata/ansible-test-ubuntu-001.sh"
  associate_public_ip_address = true
  subnet_id     = "${module.vpc.public_subnets[0]}"
	vpc_security_group_ids = ["${aws_security_group.temp_ssh_inbound.id}"]
  key_name      = "${aws_key_pair.ansible-test-key-pair.key_name}"   


  tags = "${merge(
    var.common_tags,
    map(
      "Name", "${format("%s%03d", "ec2-prd-web-", count.index + 1)}"
    )
  )}"
}


resource "aws_instance" "ansible-test-centos-001" {
  ami           = "${data.aws_ami.centos.id}"
  instance_type = "t3.nano"
  count          = 3
  user_data     = "${path.cwd}/userdata/ansible-test-centos-001.sh"
  associate_public_ip_address = true
  subnet_id     = "${module.vpc.public_subnets[0]}"
  vpc_security_group_ids = ["${aws_security_group.temp_ssh_inbound.id}"]
  key_name      = "${aws_key_pair.ansible-test-key-pair.key_name}"   


  tags = "${merge(
    var.common_tags,
    map(
      "Name", "${format("%s%03d", "ec2-prd-web-", count.index + 1)}"
    )
  )}"
}
