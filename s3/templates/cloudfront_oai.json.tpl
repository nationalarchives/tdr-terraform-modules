{
  "Version": "2012-10-17",
  "Id": "CloudfrontUploadBucketPolicy",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "${cloudfront_oai}"
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::${bucket_name}/*"
    },
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::${bucket_name}/*",
      "Condition": {
        "StringEquals": {
          "aws:sourceVpce": "${vpc_endpoint_id}"
        }
      }
    }
  ]
}
