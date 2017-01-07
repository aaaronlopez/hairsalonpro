require 'google/apis/calendar_v3'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'google/api_client/client_secrets'
require 'fileutils'

module GoogleCalendar
  OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'
  APPLICATION_NAME = 'Google Calendar API Ruby Quickstart'
  CLIENT_SECRETS_PATH = 'lib/assets/.client_secret.json'
  CREDENTIALS_PATH = File.join(Dir.home, '.credentials',
                               "calendar-ruby-quickstart.yaml")
  SCOPE = Google::Apis::CalendarV3::AUTH_CALENDAR
  # TODO: Maybe make this a global config constants.
  CALENDAR_ID = 'chq0o4uupm97nqfmdliia73bkc@group.calendar.google.com'

  # API Initialization
  FileUtils.mkdir_p(File.dirname(CREDENTIALS_PATH))
  client_id = Google::Auth::ClientId.from_hash(JSON.parse(ENV['GOOGLE_CLIENT_SECRETS']))
  token_store = Google::Auth::Stores::FileTokenStore.new(file: CREDENTIALS_PATH)
  authorizer = Google::Auth::UserAuthorizer.new(
    client_id, SCOPE, token_store)
  user_id = 'default'
  credentials = authorizer.get_credentials(user_id)
  if credentials.nil?
    url = authorizer.get_authorization_url(
      base_url: OOB_URI)
    puts "Open the following URL in the browser and enter the " +
         "resulting code after authorization"
    puts url
    code = gets
    credentials = authorizer.get_and_store_credentials_from_code(
      user_id: user_id, code: code, base_url: OOB_URI)
  end

  @@service = Google::Apis::CalendarV3::CalendarService.new
  @@service.client_options.application_name = APPLICATION_NAME
  @@service.authorization = credentials

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
    #puts "Event created: #{result.html_link}"
  end

  def delete_calendar_event(event_id)
    @@service.delete_event(CALENDAR_ID, event_id)
  end
end
