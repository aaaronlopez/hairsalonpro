class NotificationsController < ApplicationController
  #skip_before_action :verify_authenticity_token
 
  def notify
    client = Twilio::REST::Client.new TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN
    message = client.messages.create(
      from: TWILIO_NUMBER,
      to: '+17602358826',
      body: 'Learning to send SMS you are.',
      media_url: 'http://linode.rabasa.com/yoda.gif'
    )
    render plain: message.status
  end
end