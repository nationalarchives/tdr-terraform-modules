{
  "Id": "secure-transport-${bucket_name}",
  "Version": "2012-10-17",
  "Statement": [
  %{ for grant in canonical_user_grants ~}
    {
      "Sid": "GrantPermissions-${grant.id}",
      "Effect": "Allow",
      "Principal": {
        "AWS": "${grant.id}"
      },
      "Action": ${grant.permissions},
      "Resource": [
        "arn:aws:s3:::${bucket_name}",
        "arn:aws:s3:::${bucket_name}/*"
       ]
      }%{ if for.index != canonical_user_grants.length - 1 ~},%{ endif }
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