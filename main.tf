provider "aws" {
  alias = "east"
  region = "us-east-1"
}

provider "aws" {
  alias  = "west"
  region = "us-west-2"
}

resource "aws_s3_bucket" "bucket1" {
  provider = aws.east
  bucket = "sourcebucket1-gga"
  versioning {
    enabled = true
  }
}

resource "aws_s3_bucket" "bucket2" {
  provider = aws.west
  bucket = "resbucket2-gga"
  versioning {
    enabled = true
  }
}


resource "aws_iam_policy" "replication_policy" {
  name        = "s3-replication-policy"
  policy      = jsonencode({
   "Version":"2012-10-17",
   "Statement":[
      {
         "Effect":"Allow",
         "Action":[
            "s3:GetReplicationConfiguration",
            "s3:ListBucket"
         ],
         "Resource":[
            "arn:aws:s3:::${aws_s3_bucket.bucket1.id}"
         ]
      },
      {
         "Effect":"Allow",
         "Action":[
            "s3:GetObjectVersionForReplication",
            "s3:GetObjectVersionAcl",
            "s3:GetObjectVersionTagging"
         ],
         "Resource":[
            "arn:aws:s3:::${aws_s3_bucket.bucket1.id}/*"
         ]
      },
      {
         "Effect":"Allow",
         "Action":[
            "s3:ReplicateObject",
            "s3:ReplicateDelete",
            "s3:ReplicateTags"
         ],
         "Resource":"arn:aws:s3:::${aws_s3_bucket.bucket2.id}/*"
      }
   ]
  })
}

resource "aws_iam_role" "s3_role" {
  name = "s3-replication-role"
  path = "/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "s3_role_policy" {
  policy_arn = aws_iam_policy.replication_policy.arn
  role       = aws_iam_role.s3_role.name
}

resource "aws_s3_bucket_replication_configuration" "replication_configuration" {

  role   = aws_iam_role.s3_role.arn
  bucket = aws_s3_bucket.bucket1.id


  rule {
    status = "Enabled"

    destination {
      bucket        = aws_s3_bucket.bucket2.arn
      //storage_class = "STANDARD"
      //replica_kms_key_id = "arn:aws:kms:us-west-2:111122223333:key/1234abcd-12ab-34cd-56ef-1234567890ab"
    }
  }
}
