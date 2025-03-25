provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "ubuntu_instance" {
  ami           = "ami-084568db4383264d4" 
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_subnet.id
  security_groups = [aws_security_group.ubuntu_sg.name]

  tags = {
    Name = "Ubuntu-Instance"
  }
}

resource "aws_instance" "amazon_linux_instance" {
  ami           = "ami-08b5b3a93ed654d19"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_subnet.id

  tags = {
    Name = "AmazonLinux-Instance"
  }
}
