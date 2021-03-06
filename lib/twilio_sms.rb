module TwilioSms
  def send_sms(twilio_number, phone_number, message, media_url)
    client = Twilio::REST::Client.new Rails.application.secrets.twilio_account_sid, Rails.application.secrets.twilio_auth_token
    if media_url
      message = client.messages.create(
        from: twilio_number,
        to: phone_number,
        body: message,
        media_url: media_url
      )
    else
      message = client.messages.create(
        from: twilio_number,
        to: phone_number,
        body: message
      )
    end
  end
end
