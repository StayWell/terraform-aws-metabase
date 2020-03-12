module "metabase" {
  source             = "../"
  public_subnet_ids  = module.vpc.public_subnets_ids
  private_subnet_ids = module.vpc.private_subnets_ids
  domain             = "metabase.devops-staywell.com"
}

module "vpc" {
  source  = "StayWell/smart-vpc/aws"
  version = "0.3.1"
}

provider "aws" {
  region = "us-east-1"
}
