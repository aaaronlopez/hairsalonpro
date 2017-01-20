require 'google/apis/calendar_v3'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'google/api_client/client_secrets'
require 'google/apis/compute_v1'
require 'fileutils'

module GoogleCalendar
  OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'
  APPLICATION_NAME = 'Hair Salon Pro'
  CLIENT_SECRETS_PATH = 'lib/assets/.client_secret.json'
  CREDENTIALS_PATH = File.join(Dir.home, '.credentials',
                               "calendar-ruby-quickstart.yaml")
  SCOPE = Google::Apis::CalendarV3::AUTH_CALENDAR
  # TODO: Maybe make this a global config constants.
  CALENDAR_ID = 'chq0o4uupm97nqfmdliia73bkc@group.calendar.google.com'

  @@service = Google::Apis::CalendarV3::CalendarService.new
  @@service.client_options.application_name = APPLICATION_NAME
  @@service.authorization = Google::Auth.get_application_default([SCOPE])

  # @return array of events between time_min and time_max
  def list_events_by_time(time_min, time_max)
    response = @@service.list_events(CALENDAR_ID,
                                   single_events: true,
                                   order_by: 'startTime',
                                   time_min: time_min,
                                   time_max: time_max)
    events = []
    response.items.each do |event|
      events.push([event.start.date_time, event.end.date_time])
    end
    events
  end

  def insert_calendar_event(start_time, end_time, title, location)
    event = Google::Apis::CalendarV3::Event.new(
      summary: title,
      location: location,
      start: {
        date_time: start_time,
        time_zone: 'America/Los_Angeles',
      },
      end: {
        date_time: end_time,
        time_zone: 'America/Los_Angeles',
      }
    )
    result = @@service.insert_event(CALENDAR_ID, event)
  end

  def delete_calendar_event(event_id)
    @@service.delete_event(CALENDAR_ID, event_id)
  end
end
