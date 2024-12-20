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
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:ListBucket",
        "s3:GetBucketLocation",
        "s3:GetBucketAcl",
        "s3:PutBucketAcl",
        "s3:DeleteBucket"
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