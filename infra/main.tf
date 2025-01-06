provider "aws" {
  region = "us-west-2"
}
variable "instance_type" {
  description = "Type of EC2 instance"
  default     = "t2.micro"
}
resource "aws_instance" "example" {
  ami           = "ami-05d38da78ce859165"
  instance_type = var.instance_type

  tags = {
    Name = "ExampleInstance"
  }
}

