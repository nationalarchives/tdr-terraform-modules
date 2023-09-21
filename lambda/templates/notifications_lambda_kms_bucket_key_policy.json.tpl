{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DecryptS3Bucket",
      "Effect": "Allow",
      "Action": [
        "kms:Decrypt",
        "kms:GenerateDataKey*"
      ],
      "Resource": [
        "${kms_export_bucket_key_arn}"
      ]
    }
  ]
}
