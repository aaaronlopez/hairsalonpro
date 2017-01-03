class SmsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def new_customer
    @customer = Customer.find(params[:customer_id])
    @admin = Admin.find(@customer.admin)
    message = 'Welcome to Hair Salon Pro, #{@customer.first_name}!\n You have'\
      ' been added as a customer by #{@admin.first_name}. Please respond to this'\
      ' number at any time to for any information or to make an appointment.'
    send_message(@admin.phone_number, @customer.phone_number, message, '')
    #render plain: message.status
    redirect_to root_path
  end

  private
  def send_message(twilio_number, phone_number, message, media_url)
    client = Twilio::REST::Client.new TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN
    message = client.messages.create(
      from: twilio_number,
      to: phone_number,
      body: message,
      media_url: media_url
    )
  end
end
