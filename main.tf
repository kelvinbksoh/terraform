# terraform apply -var-file="variable.tfvars"
variable "region" {}
variable "profile" {}

variable server_port {
    description = "The port the server will use for HTTP requests"
    type = number
    default     = 8080
}

variable "my_ami" {
    type = "map"
}

provider "aws" {
  region                  = "${var.region}"
  profile                 = "${var.profile}"
}

# resource "<PROVIDER>_<TYPE>" "<NAME>" { [CONFIG ...]}
resource "aws_instance" "web_server" { # creating resources for aws provider
  # count = 1 # create 10 ec2 instances
  ami = "${lookup(var.my_ami, var.region)}"
  instance_type = "t1.micro"
  vpc_security_group_ids = [aws_security_group.web_security_group.id]
  # user_data = "${file("install_vault.sh")}" # Bash script that executes when the server is booting
  user_data = "${file("hello_world.sh")}"
  key_name = "mykey" # tag a key pair when creating instances
  tags = {
      Name = "Web Server"
  }
}

resource "aws_security_group" "web_security_group" {
  name = "web-server-instance"
  # Allow EC2 Instance to receive traffic on port 8080
  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
    # allow incoming TCP request on port 8080 from the CIDR block 0.0.0.0/0 (any IP).
    # CIDR blocks are a concise way to specify IP address ranges.
  }
}

output "public_ip" {
  value         = aws_instance.web_server.public_ip
  description   = "The public IP address of the web server"
}