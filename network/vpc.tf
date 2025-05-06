resource "aws_vpc" "main" {
  tags = {
    Name = "main-vpc"
  }
}