class TokBoxService
  require "opentok"

  def initialize(visit)
    @opentok = OpenTok::OpenTok.new ApplicationConfig["TOK_API_#{visit.codec_postfix}"], ApplicationConfig["TOK_SECRET_#{visit.codec_postfix}"]
    @visit = visit
  end

  def get_archive
    @archive = @opentok.archives.all(sessionId: Visit.last.tok_session_id)
  end

  def set_and_save_data
    options = if @visit.organization.enable_recording && @visit.organization.can?(Permission::RECORDING)
      { media_mode: :routed, archive_mode: :always}
    else
      { media_mode: :relayed}
    end

    @session = @opentok.create_session options
    @visit.update(tok_session_id: @session.session_id)
  end

  def generate_token
    return '' if @visit.tok_session_id.blank? || @visit.no_codec?

    @opentok.generate_token(@visit.tok_session_id, {
        :expire_time => Time.now.to_i + (21 * 24 * 60 * 60), # in three weeks
        :data        => "visit_id=#{@visit.id}"
    });
  end

  def set_demo_visit_data
    @session = @opentok.create_session :media_mode => :routed
    @visit.update(tok_session_id: @session.session_id)
  end
end
