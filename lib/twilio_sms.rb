module TwilioSms
  def send_sms(twilio_number, phone_number, message, media_url)
    client = Twilio::REST::Client.new TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN
    message = client.messages.create(
      from: twilio_number,
      to: phone_number,
      body: message,
      media_url: media_url
    )
  end
end