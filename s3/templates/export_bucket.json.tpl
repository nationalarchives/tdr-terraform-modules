{
  "Id": "secure-transport-${bucket_name}",
  "Version": "2012-10-17",
  "Statement": [
    %{ for grant in jsondecode(canonical_user_grants) ~}
      {
      "Sid": "GrantPermissions-${grant.id}",
      "Effect": "Allow",
      "Principal": {
        "AWS": "${grant.id}"
      },
      "Action": ${jsonencode(grant.permissions)},
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
    },
    {
      "Sid": "AllowReadAccess",
      "Effect": "Allow",
      "Principal": {
        "AWS": ${jsonencode(read_access_roles)}
      },
      "Action": [
        "s3:GetObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::${bucket_name}",
        "arn:aws:s3:::${bucket_name}/*"
      ]
    }
  ]
}