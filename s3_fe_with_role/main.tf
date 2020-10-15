variable "S3_FE_NAME" {}

resource "aws_s3_bucket" "s3_fe" {
  bucket = var.S3_FE_NAME

  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Id" : "Public Website",
      "Statement" : [
        {
          "Sid" : "1",
          "Effect" : "Allow",
          "Principal" : "*",
          "Action" : "s3:GetObject",
          "Resource" : "arn:aws:s3:::${var.S3_FE_NAME}/*"
        }
      ]
    }
  )
  cors_rule {
    allowed_headers = [
      "*",
    ]
    allowed_methods = [
      "GET",
      "HEAD",
    ]
    allowed_origins = [
      "*",
    ]
    expose_headers  = []
    max_age_seconds = 0
  }

  versioning {
    enabled    = true
    mfa_delete = false
  }

  website {
    error_document = "index.html"
    index_document = "index.html"
  }
}

resource "aws_iam_policy" "policy_s3_fe" {
  name ="s3_fe_${var.S3_FE_NAME}"
  policy = jsonencode(
    {
      Statement = [
        {
          Action = [
            "s3:GetAccessPoint",
            "s3:PutAccountPublicAccessBlock",
            "s3:GetAccountPublicAccessBlock",
            "s3:ListAllMyBuckets",
            "s3:ListAccessPoints",
            "s3:ListJobs",
            "s3:CreateJob",
            "s3:HeadBucket",
          ]
          Effect   = "Allow"
          Resource = "*"
          Sid      = "VisualEditor0"
        },
        {
          Action = "s3:*"
          Effect = "Allow"
          Resource = [
            "arn:aws:s3:::${var.S3_FE_NAME}",
            "arn:aws:s3:::${var.S3_FE_NAME}/*",
          ]
          Sid = ""
        },
      ]
      Version = "2012-10-17"
    }
  )
}

resource "aws_iam_role" "role_s3_fe" {
  assume_role_policy = jsonencode(
    {
      Statement = [
        {
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = {
            Service = "ec2.amazonaws.com"
          }
          Sid = ""
        },
      ]
      Version = "2012-10-17"
    }
  )
}

resource "aws_iam_user" "devops_user0" {
  name = "devops_user0"
}

resource "aws_iam_access_key" "devops_user0_access" {
  user    = aws_iam_user.devops_user0.name
}

output "output" {
  value = {
    "username": "${aws_iam_user.devops_user0.name}",
    "access": "${aws_iam_access_key.devops_user0_access.id}",
    "secret": "${aws_iam_access_key.devops_user0_access.secret}",
    "role_s3_fe" : "${aws_iam_role.role_s3_fe.arn}",
    "s3_website" : "${aws_s3_bucket.s3_fe.website_domain}"
    }
  
  # sensitive   = true
}

resource "aws_iam_role_policy_attachment" "role_att_s3_fe" {
  role       = aws_iam_role.role_s3_fe.name
  policy_arn = aws_iam_policy.policy_s3_fe.arn
}

resource "aws_iam_user_policy_attachment" "role_att_s3_fe" {
  user       = aws_iam_user.devops_user0.name
  policy_arn = aws_iam_policy.policy_s3_fe.arn
}
