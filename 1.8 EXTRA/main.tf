provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = false
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "ubuntu_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "amazon_linux_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.public.cidr_block] 
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/16"]
  }
}

resource "aws_key_pair" "my_key" {
  key_name   = "my-key"
  public_key = file("./my-key.pub")
}

resource "aws_instance" "ubuntu" {
  ami               = "ami-084568db4383264d4"
  instance_type     = "t2.micro"
  subnet_id         = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.ubuntu_sg.id]
  associate_public_ip_address = true
  key_name          = aws_key_pair.my_key.key_name 

  tags = {
    Name = "Ubuntu-Instance"
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install -y nginx docker.io curl
              echo "<html><body><h1>Hello World</h1><p>OS Version: $(lsb_release -d | cut -f2)</p></body></html>" | sudo tee /var/www/html/index.html
              sudo systemctl start nginx
              sudo systemctl enable nginx
              sudo systemctl start docker
              sudo systemctl enable docker
              EOF
  depends_on = [aws_security_group.ubuntu_sg]
}


resource "aws_instance" "amazon_linux" {
  ami               = "ami-08b5b3a93ed654d19"
  instance_type     = "t2.micro"
  subnet_id         = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.amazon_linux_sg.id]
  key_name          = aws_key_pair.my_key.key_name 

  tags = {
    Name = "AmazonLinux-Instance"
  }

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y nginx
              echo "Hello World - Amazon Linux" > /usr/share/nginx/html/index.html
              systemctl start nginx
              systemctl enable nginx
              EOF
}
