provider "aws" {
  region = "us-east-1" 
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-amd64-server-*"]
  }
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["137112412989"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "ubuntu" {
  ami               = data.aws_ami.ubuntu.id
  instance_type     = "t2.micro"
  tags = {
    Name = "Ubuntu-Instance"
  }
}

resource "aws_instance" "amazon_linux" {
  ami               = data.aws_ami.amazon_linux.id
  instance_type     = "t2.micro"
  tags = {
    Name = "AmazonLinux-Instance"
  }
}
