{
  "Id": "secure-transport-${bucket_name}",
  "Version": "2012-10-17",
  "Statement": [
  %{ for grant in jsondecode(canonical_user_grants) ~}
    {
      "Sid": "GrantPermissions-${grant.id}",
      "Effect": "Allow",
      "Principal": {
        "CanonicalUser": "${grant.id}"
      },
        "Action": [
        "s3:GetBucketAcl",
        "s3:ListBucket",
        "s3:PutBucketAcl",
        "s3:PutObject"
    ],
      "Resource": [
        "arn:aws:s3:::${bucket_name}",
        "arn:aws:s3:::${bucket_name}/*"
      ]
    },
  %{ endfor ~}
   {
      "Sid": "AllowSSLRequestsOnly",
      "Action": "s3:*",
      "Effect": "Deny",
      "Resource": [
        "arn:aws:s3:::${bucket_name}",
        "arn:aws:s3:::${bucket_name}/*"
      ],
      "Condition": {
        "Bool": {
          "aws:SecureTransport": "false"
        }
      },
      "Principal": "*"
   }
  ]
}
