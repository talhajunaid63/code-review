class CopyOldRecordingsService
  attr_reader :organization, :recordings_before_date

  def initialize(organization, recordings_before_date)
    @organization = organization
    @recordings_before_date = recordings_before_date
  end

  def perform
    recordings.each do |recording|
      next if recording.tok_id.blank?

      h264_recording_tok_id = "#{ApplicationConfig["TOK_API_H264"]}/#{recording.tok_id}"
      vp8_recording_tok_id = "#{ApplicationConfig["TOK_API_VP8"]}/#{recording.tok_id}"
      source =
        if s3_client.folder_exists?(h264_recording_tok_id)
          "#{h264_recording_tok_id}/archive.mp4"
        elsif s3_client.folder_exists?(vp8_recording_tok_id)
          "#{vp8_recording_tok_id}/archive.mp4"
        else
          next
        end

      target = "#{organization.slug}/#{recording.visit_id}/recording_#{recording.id}"

      result = Organizations::CopyBucketService.new(organization.bucket_name, source: source, target: target).perform

      Rollbar.error("FAILURE: Recording recording_#{recording.id} is failed: #{result.message}.") unless result.success?
    end
  end

  private

  def recordings
    organization
      .visit_recordings
      .not_expired
      .where('Date(created_at) <= ?', recordings_before_date)
  end

  def s3_client
    @s3_client ||= S3Client.new
  end
end