class Recordings::S3Service
  ARCHIVE_NAME = "archive.mp4"

  def initialize(recording)
    @recording = recording
  end

  def region
    ApplicationConfig["AWS_REGION"]
  end

  def bucket_name
    ApplicationConfig["S3_BUCKET_NAME"]
  end

  def s3_object(key)
    s3.bucket(bucket_name).object(key)
  end

  def s3
    @s3 ||= Aws::S3::Resource.new(region: region, credentials: credentials)
  end

  def access_key_id
    ApplicationConfig["AWS_ACCESS_KEY_ID"]
  end

  def access_key_secret
    ApplicationConfig["AWS_SECRET_ACCESS_KEY"]
  end

  def credentials
    @credentials ||= Aws::Credentials.new(access_key_id, access_key_secret)
  end

  def recording_key(name)
    "#{ApplicationConfig["TOK_API_VP8"]}/#{@recording.tok_id}/#{name}"
  end

  def archive_key
    recording_key(ARCHIVE_NAME)
  end

  def download_key
    key = [@recording.organization.slug, "visit", @recording.visit_id].join('-')
    recording_key("#{key}.mp4")
  end

  def exists?
    s3_object(archive_key).exists?
  end

  def download_url
    return unless exists?

    unless s3_object(download_key).exists?
      s3_object(archive_key).copy_to(bucket: bucket_name, key: download_key, content_disposition: "attachment", metadata_directive: "REPLACE")
    end

    s3_object(download_key).presigned_url(:get, expires_in: 3600)
  end

  def presigned_url
    s3_object(archive_key).presigned_url(:get, expires_in: 3600)
  end
end
