provider "aws" {
  region = "${var.region}"
}

data "aws_ami" "web_ami" {
  most_recent = true

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_security_group" "web_security_group" {
  name        = "Web Server Security Group"
  description = "Security Group for the Web Server"

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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web" {
  instance_type = "${var.instance_type}"
  ami           = "${data.aws_ami.web_ami.id}"

  tags {
    Name = "Web Server"
  }

  vpc_security_group_ids = ["${aws_security_group.web_security_group.id}"]

  key_name = "${var.key_name}"

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      private_key = "${file(var.private_keypath)}"
      user        = "ec2-user"
    }

    inline = [
      "sudo yum update -y",
      "sudo yum install nginx -y",
      "sudo service nginx start",
    ]
  }
}
