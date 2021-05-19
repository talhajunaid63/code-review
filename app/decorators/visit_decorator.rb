class VisitDecorator < SimpleDelegator
  extend ActiveModel::Naming

  def scheduled_time_in(time_zone=Time.zone.name)
    return if self.schedule.blank?

    schedule_time = self.schedule.in_time_zone(time_zone)

    time = [schedule_time.strftime("%A, %B #{schedule_time.day.ordinalize} %l:%M %p")]
    time << self.schedule_end.strftime("%I:%M %p") if self.schedule_end.present?

    time.join(" - ")
  end

end
