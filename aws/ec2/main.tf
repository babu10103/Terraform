provider "aws" {
  region = "ap-south-1"  
  access_key = AWS_ACCESS_KEY_ID
  secret_key = AWS_SECRET_KEY
}

resource "aws_vpc" "ansibleVpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "AnsibleVpc"
  }
}

resource "aws_subnet" "ansibleSubnet" {
  vpc_id =  aws_vpc.ansibleVpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-south-1a"
  tags = {
    Name = "subnet-1"
  }
}

resource "aws_security_group" "ansibleSG" {
  name = "sg1"
  description = "Allows TLS inbound traffic"
  vpc_id =  aws_vpc.ansibleVpc.id

  ingress {
    description = "HTTPS"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }  

  ingress {
    description = "HTTP"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Jenkins"
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  egress {
    cidr_blocks = [ "0.0.0.0/0" ]
    from_port = 0
    ipv6_cidr_blocks = [ "::/0" ]
    protocol = "-1"
    to_port = 0
  } 
}

resource "aws_network_interface" "ansibleNIC" {
  subnet_id = aws_subnet.ansibleSubnet.id
  private_ips = [ "10.0.1.50" ]
  security_groups = [aws_security_group.ansibleSG.id]
}

resource "aws_instance" "Ansible"{
  ami = "ami-01c000b97ebbcd46f"
  instance_type = "t2.micro"
  availability_zone = "ap-south-1a"
  key_name = "master-1"

  network_interface {
    device_index = 0
    network_interface_id = aws_network_interface.ansibleNIC.id
  }
  tags = {
    Name = "AnsibleMaster"
  }
}
