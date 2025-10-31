terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket"   # change
    key            = "3tier/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"             # change/create
    encrypt        = true
  }
}
