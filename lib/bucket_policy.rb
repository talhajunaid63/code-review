class BucketPolicy
  class << self
    def call(bucket_name)
      {
        Version: "2012-10-17",
        Statement: [
          {
            Sid: "GrantCopy",
            Effect: "Allow",
            Principal: {
              AWS: Rails.application.credentials[Rails.env.to_sym][:S3_COPIER_ARN]
            },
            Action: [
              "s3:ListBucket",
              "s3:GetObject",
              "s3:PutObject",
              "s3:PutObjectAcl"
            ],
            Resource: [
              "arn:aws:s3:::#{bucket_name}/*",
              "arn:aws:s3:::#{bucket_name}"
            ]
          }
        ]
      }
    end
  end
end
