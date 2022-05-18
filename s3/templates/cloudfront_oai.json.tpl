{
  "Version": "2012-10-17",
  "Id": "CloudfrontUploadBucketPolicy",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "${cloudfront_oai}"
      },
      "Action": [
        "s3:PutObject",
        "s3:PutObjectTagging"
      ],
      "Resource": "arn:aws:s3:::${bucket_name}/*"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "arn:aws:iam::${account_id}:role/TDRDownloadFilesRole",
          "arn:aws:iam::${account_id}:role/TDRYaraAvRole"
        ]
      },
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::tdr-upload-files-cloudfront-dirty-${environment}/*"
    }
  ]
}
