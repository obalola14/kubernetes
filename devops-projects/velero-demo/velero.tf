resource "random_string" "random" {
  length           = 10
  special          = false
  upper            = false 
}

module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "valero-bucket-${random_string.random.result}"
  acl    = "private"
  force_destroy = true

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  versioning = {
    enabled = true
  }
}

resource "aws_iam_user" "valero" {
  name = "valero-user"

  tags = {
    Project = "Valero-project"
  }
}

resource "aws_iam_user_policy" "valero" {
  name   = "valero-policy"
  user   = aws_iam_user.valero.name
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeVolumes",
                "ec2:DescribeSnapshots",
                "ec2:CreateTags",
                "ec2:CreateVolume",
                "ec2:CreateSnapshot",
                "ec2:DeleteSnapshot"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:DeleteObject",
                "s3:PutObject",
                "s3:AbortMultipartUpload",
                "s3:ListMultipartUploadParts"
            ],
            "Resource": [
                "arn:aws:s3:::${module.s3_bucket.s3_bucket_id}/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::${module.s3_bucket.s3_bucket_id}"
            ]
        }
    ]
}
POLICY 
}

resource "aws_iam_access_key" "valero" {
  user    = aws_iam_user.valero.name
}