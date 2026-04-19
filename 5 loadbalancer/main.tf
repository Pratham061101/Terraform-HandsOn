terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"

}

resource "aws_default_vpc" "default" {

}

resource "aws_security_group" "aws_server_sg" {
  name = "http_server_sg"
  //vpc_id = "vpc-07ce6c0a4a264a4c2"
  vpc_id = aws_default_vpc.default.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    name = "http_server_sg"
  }
}


resource "aws_security_group" "elb_sg" {
  name = "elb_sg"
  //vpc_id = "vpc-07ce6c0a4a264a4c2"
  vpc_id = aws_default_vpc.default.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    name = "elb_sg"
  }
}

resource "aws_elb" "elb" {
  name = "elb"
  subnets = data.aws_subnets.default_subnets.ids
  security_groups = [aws_security_group.elb_sg.id]
  instances = values(aws_instance.http_servers).*.id


  listener {
    instance_port = 80
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }

}

resource "aws_instance" "http_servers" {
  //ami                    = "ami-02dfbd4ff395f2a1b"
  ami                    = data.aws_ami.aws-linux-2-latest.id
  key_name               = "default-ec2"
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.aws_server_sg.id]
  for_each               = toset(local.supported_subnets)
  subnet_id              = each.value
  //subnet_id              = data.aws_subnets.default_subnets.ids[0]
  //subnet_id              = "subnet-0f9f1bc37c0e40d6d"

  tags = {
    name = "http_server_${each.value}"
  }


  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ec2-user"
    private_key = file(var.aws_key_pair)
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum install httpd -y",
      "sudo service httpd start",
      "echo First EC2 using Terraform - Virtual Server is at ${self.public_dns} | sudo tee /var/www/html/index.html"
    ]
  }
}