class ExportVisitsCsvService

  def initialize(visits)
    @visits = visits
  end

  def process
    CSV.generate(headers: true) do |csv|
      csv << attributes

      @visits.includes(:voip_call_logs).each do |visit|
        csv << data_for(visit)
      end
    end
  end

  def attributes
    [
      'id',
      'state',
      'type',
      'patient_id',
      'patient_full_name',
      'coordinators_full_name',
      'providers_full_name',
      'scheduled_date_time',
      'scheduled_end_time',
      'organization_name',
      'auth_number',
      'consented_by',
      'provider_notes',
      'reason_for_visit',
      'internal_notes',
      'visit_duration',
      'patient_browser',
      'provider_browser',
      'provider_attendance',
      'patient_attendance',
      'successful_connection',
      'created_at',
      'updated_at',
      'last_pretest_status',
      'last_pretest_completed_at',
      'voip_call_logs (start_time - end_time)',
    ]
  end

  def data_for(visit)
    incident_info = visit.incident_information&.incident_description, visit.incident_information&.activity_performed if visit.incident_information.present?

    [
       visit.id,
       visit.state,
       visit.type,
       visit.patient&.id,
       visit.patient&.name,
       visit.coordinators_names.join(','),
       visit.providers_names.join(','),
       visit.scheduled_time,
       format_date(visit.schedule_end),
       visit.organization.name,
       visit.auth_number,
       visit.consented_by,
       visit.provider_notes,
       visit.incident_information.present? ? incident_info.reject(&:empty?).join(',') : visit.patient_notes,
       visit.internal_notes,
       visit.duration,
       browser_info(visit, [visit.patient_id]),
       browser_info(visit, visit.providers.ids),
       user_attendance(visit, visit.providers.ids),
       user_attendance(visit, [visit.patient_id]),
       connected?(visit),
       format_date(visit.created_at),
       format_date(visit.updated_at),
       pre_test_status(visit),
       pre_test_completed_at(visit.patient),
       visit.voip_call_logs_time_range
    ]
  end

  def format_date(date_time)
    Utils.format_date(date_time, "%A, %B #{date_time&.utc&.day&.ordinalize} %l:%M %p %Z")
  end

  def browser_info(visit, user_ids)
    video_log = visit.video_logs.select { |video_log| user_ids&.include?(video_log.user_id) }.first
    return if video_log.blank?

    [video_log.os, video_log.os_version, video_log.browser, video_log.browser_version].compact.join(' ')
  end

  def user_attendance(visit, user_ids)
    attendance = visit.attendances.select { |attendance| user_ids&.include?(attendance.user_id) }.first
    return if attendance.blank?

    format_date(attendance.created_at)
  end

  def connected?(visit)
    visit.video_logs.collect(&:msg).include?('Stream is Successfully Created for Visit.')
  end

  def pre_test_status(visit)
    visit.patient&.pre_test&.category_status&.titleize
  end

  def pre_test_completed_at(patient)
    pre_test_completed_at = patient&.pre_test&.ensure_pre_test_detail&.attempted_at
    return if pre_test_completed_at.blank?

    format_date(pre_test_completed_at)
  end
end
