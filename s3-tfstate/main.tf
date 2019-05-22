#Terraform State bucket

resource "aws_s3_bucket" "tfstate" {
	bucket = "${var.tfstate_bucket_name}"
  acl    = "private"
  region = "us-west-2"

  tags = {
	  Name = "${var.tfstate_bucket_name}"
    owner = "foo"
  }
}
