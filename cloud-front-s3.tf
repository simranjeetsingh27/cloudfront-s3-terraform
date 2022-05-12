#provider "aws" {
#  version = "~> 2.57.0"
#}

provider "random" {
  version = "~> 2.2.1"
}

data "aws_caller_identity" "current" {} # used for accesing Account ID and ARN




##################################################################
# Variable declaration session
# Uncomment default and put require strings to input values directly 


variable "value1" {

 description = "Please Input the ENV name:(Eg:develop/staging/production)"
# default = "Dev"
}

variable "value2" {

 description = "Please Input resource name tag (Eg : demo , productnametag .. etc)"
# default = ""
}

variable "value3" {

 description = "Please Input the aws region name"
# default = ""
}





provider "aws" {
  region = "${var.value3}"
}


###############################################
#S3bucket static website


resource "aws_s3_bucket" "s3bucket-provision" {
  bucket = "${var.value1}-${var.value2}"
  acl    = "private"


  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "AES256"
      }
    }
}


  website {
    index_document = "index.html"
    error_document = "index.html"

    routing_rules = <<EOF

[
    {
        "Condition": {
            "HttpErrorCodeReturnedEquals": "403"
        },
        "Redirect": {
            "HostName": "inputs3bucketURL",
            "ReplaceKeyPrefixWith": "#"
        }
    }
]


EOF
  }
}

###############################################
#Cloudfront

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = ""
}


###############################################

locals {
  s3_origin_id = "${var.value1}-${var.value2}"
}


resource "aws_cloudfront_distribution" "cloudfront_provisioning" {
  origin {
    domain_name = "${var.value1}-${var.value2}.s3.${var.value3}.amazonaws.com"
    origin_id   = local.s3_origin_id


    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }


  }

  enabled             = true
  is_ipv6_enabled     = false
  comment             = "cloudfront"
  default_root_object = "index.html"

default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id


    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400

    compress               = true
  }

price_class = "PriceClass_200"

  restrictions {
    geo_restriction {
      restriction_type = "none"
#      locations        = ["US", "CA", "GB", "DE"]
    }
  }




  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

###############################################
#S3policy

data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.s3bucket-provision.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "s3bucket-provision" {
  bucket = aws_s3_bucket.s3bucket-provision.id
  policy = data.aws_iam_policy_document.s3_policy.json
}

resource "aws_s3_bucket_public_access_block" "s3bucket-provision" {
  bucket = aws_s3_bucket.s3bucket-provision.id

  block_public_acls       = true
  block_public_policy     = true

  ignore_public_acls      = true
  restrict_public_buckets = true
}


