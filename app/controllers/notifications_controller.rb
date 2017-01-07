class NotificationsController < ApplicationController
  #skip_before_action :verify_authenticity_token
 
  def notify
    client = Twilio::REST::Client.new Rails.application.secrets.twilio_account_sid, Rails.application.secrets.twilio_auth_token
    message = client.messages.create(
      from: TWILIO_NUMBER,
      to: '+17602358826',
      body: 'Learning to send SMS you are.',
      media_url: 'http://linode.rabasa.com/yoda.gif'
    )
    render plain: message.status
  end
end