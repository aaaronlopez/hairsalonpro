require 'google_calendar'

class Appointment < ApplicationRecord
  include GoogleCalendar

  belongs_to :customer

  validates :start_time, presence: true
  validates :end_time, presence: true
  validate :start_cannot_be_greater_than_end, :time_cannot_be_in_the_past,
    :appointments_cannot_be_greater_than_limit
  #validate :appointment_during_working_hours
  validate :appointment_cannot_overlap

  @@REMINDER_TIME = 30.minutes

  @@open_times = [nil, [8, 18], [8, 18], [8, 18], [8, 18], [8, 18]]
  @@open_days = [false, true, true, true, true, true, false]
  @@appt_minute_limit = 90
  @@open_hour = 8
  @@close_hour = 16

  def start_cannot_be_greater_than_end
    if start_time >= end_time
      errors.add(:start_time, "must be before end")
    end
  end

  def time_cannot_be_in_the_past
    if start_time < Time.now
      errors.add(:start_time, "can't be in the past")
    end
    if end_time < Time.now
      errors.add(:end_time, "can't be in the past")
    end
  end

  def appointment_during_working_hours
    if not @@open_days[start_time.wday]
      errors.add(:start_time, "must be on an open day")
    elsif start_time.hour < @@open_times[start_time.wday][0] or start_time.hour > @@open_times[start_time.wday][1]
      errors.add(:start_time, "must be during working hours")
    elsif end_time.hour < @@open_times[start_time.wday][0] or end_time.hour > @@open_times[start_time.wday][1]
      errors.add(:end_time, "must be during working hours")
    else

    end
  end

  def appointments_cannot_be_greater_than_limit
    if ((end_time - start_time) / 60) > @@appt_minute_limit
      errors.add(:start_time, " and end time difference must be less than or equal to #{@appt_minute_limit} minutes.")
    end
  end

  def appointment_cannot_overlap
    # TODO: Change variables to global constants.
    day_start = Time.new(start_time.year, start_time.month, start_time.day, 8, 0, 0).iso8601
    day_end = Time.new(start_time.year, start_time.month, start_time.day, 16, 0, 0).iso8601
    events_by_day = list_events_by_time(day_start, day_end)
    events_by_day.each do |event|
      a = event[0].utc + Time.zone_offset('PST')
      b = event[1].utc + Time.zone_offset('PST')
      if end_time >= a and start_time <= b
        errors.add(:start_time, " and end time interfere with current schedule.")
      end
    end
  end

  def reminder
    client = Twilio::REST::Client.new TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN
    time_str = ((self.time).localtime).strftime("%I:%M%p on %b. %d, %Y")
    reminder = "Hi #{self.customer.name}. Just a reminder that you have an appointment coming up at #{time_str}."
    message = @client.account.messages.create(
      :from => TWILIO_NUMBER,
      :to => self.customer.phone_number,
      :body => reminder,
    )
    puts message.to
  end

  def when_to_run
    time - @@REMINDER_TIME
  end

  # handle_asynchronously :reminder, :run_at => Proc.new { |i| i.when_to_run }
end
