module "metabase" {
  source             = "../"
  public_subnet_ids  = ["${aws_subnet.a.id}","${aws_subnet.b.id}"]
  private_subnet_ids = ["${aws_subnet.a.id}","${aws_subnet.b.id}"]
  vpc_id             = aws_vpc.this.id
  domain             = "metabase.devops-staywell.com"
  certificate_arn    = "blah"
  zone_id            = "blah"
}

resource "aws_vpc" "this" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "a" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = cidrsubnet("10.0.0.0/16", 4, 0)
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "b" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = cidrsubnet("10.0.0.0/16", 4, 1)
  availability_zone = "us-east-1b"
}

provider "aws" {
  region = "us-east-1"
}
