provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "ubuntu_instance" {
  ami           = "ami-084568db4383264d4" 
  instance_type = "t2.micro"

  tags = {
    Name = "Ubuntu-Instance"
  }
}

resource "aws_instance" "amazon_linux_instance" {
  ami           = "ami-08b5b3a93ed654d19"
  instance_type = "t2.micro"

  tags = {
    Name = "AmazonLinux-Instance"
  }
}
