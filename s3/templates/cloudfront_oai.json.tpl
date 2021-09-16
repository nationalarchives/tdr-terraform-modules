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
    }
  ]
}
