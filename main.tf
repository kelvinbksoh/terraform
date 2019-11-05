# terraform apply -var-file="variable.tfvars"
variable "region" {}
variable "profile" {}
variable "my_ami" {
    type = "map"
}

provider "aws" {
  region                  = "${var.region}"
  profile                 = "${var.profile}"
}

# resource "<PROVIDER>_<TYPE>" "<NAME>" { [CONFIG ...]}
resource "aws_instance" "vault_server" { # creating resources for aws provider
  count = 1 # create 10 ec2 instances
  ami = "${lookup(var.my_ami, var.region)}"
  instance_type = "t1.micro"
  user_data = "${file("install_vault.sh")}" # Bash script that executes when the server is booting
  key_name = "mykey" # tag a key pair when creating instances
  tags = {
      Name = "Vault Server"
  }
}

