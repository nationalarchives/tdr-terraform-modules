{
  "Id": "secure-transport-${bucket_name}",
  "Version": "2012-10-17",
  "Statement": [
  %{ if aws_logs_delivery_account_id != "" }
    {
      "Sid": "GrantPermissionsLogging",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
           "arn:aws:iam::${account_id}:root",
           "arn:aws:iam::${aws_logs_delivery_account_id}:root"
        ]
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
    %{ endif }
    %{ if aws_backup_local_role != "" }
      {
        "Sid": "AllowSourceAWSBackupRoleAccess",
        "Effect": "Allow",
        "Principal": {
          "AWS": "${aws_backup_local_role}"
        },
        "Action": [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:ListBucket",
          "s3:ListBucketVersions"
        ],
        "Resource": [
          "arn:aws:s3:::${bucket_name}",
          "arn:aws:s3:::${bucket_name}/*"
        ]
      },
    %{ endif }
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
