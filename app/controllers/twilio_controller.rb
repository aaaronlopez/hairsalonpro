require 'twilio-ruby'
 
class TwilioController < ApplicationController
  include Webhookable
 
  after_filter :set_header
 
  #skip_before_action :verify_authenticity_token
 
  def voice
  	response = Twilio::TwiML::Response.new do |r|
  	  r.Say 'Hey there. Congrats on integrating Twilio into your Rails 4 app.', :voice => 'alice'
         r.Play 'http://linode.rabasa.com/cantina.mp3'
  	end
 
  	render_twiml response
  end

  def receive_msg   
    session["counter"] ||= 0
    sms_count = session["counter"]
    
    phone_number = params["From"]
    response = params["Body"]
    customer = Customer.find_by(phone_number: phone_number)

    case sms_count
    when 0
      if customer
        message = "Welcome back to Hair Salon Pro, #{customer.first_name}!\n\n"\
          " Respond with '1' if you'd like to find the nearest walk-in time today.\n"\
          " Respond with '2' if you'd like to make a future appointment.\n"\
          " Respond with '3' for other.\n"
      else
        message = "Welcome to Hair Salon Pro, #{params["From"]}! We do not have"\
          " your number on record. Would you like to be added as a customer?\n\n"\
          " Respond with 'yes' or 'no'."
      end
      sms_count += 1
    when 1
      if customer
        if response == "1"
          message = "Yay! The nearest walk-in today is at 2:00pm with Admin1.\n"\
          " Respond with 'yes' if you'd like to take this walk-in appointment."\
          " Respond with 'no' if you'd like a later one."
        elsif response = "2"
          message = "Yay! The nearest appointment is on 12/31/2016 at 3:00pm with Admin1.\n"\
          " Respond with 'yes' if you'd like to take this appointment."\
          " Respond with 'no' if you'd like a later one."
        else
          message = "We currently don't have any other options."
        end
      else
        if response == "yes"
          message = "Please respond with your first and last name."
        else
          message = "No to be added as a customer."
        end
      end
      sms_count += 1
    when 2
      if customer
        if response == "yes"
          message = "Great! Your appointment has been scheduled!"
        elsif response == "no"
          message = "Currently not available."
        else
          message = "There was an issue with your response."
        end
      else
        resp_array = response.split(" ")
        first_name = resp_array[0]
        last_name = resp_array[1]
        admins = Admin.all
        customer = Customer.create(first_name: first_name, last_name: last_name,
          phone_number: phone_number, admin_id: admins[0].id)
        if customer.valid?
          message = "You have been successfully added as a customer.\n\nPlease"\
        " respond to this number at any time for any information or to make an"\
        " appointment."
        else
          message = "There was an issue with your response."
        end

      end
      sms_count = 0
    else
      message = "next message #{sms_count}"
      sms_count += 1
    end

    #{"ToCountry"=>"US", "ToState"=>"CA", "SmsMessageSid"=>"SMbce9fbb7a215f98319f37076628823bc", "NumMedia"=>"0", "ToCity"=>"EL CENTRO", "FromZip"=>"92243", "SmsSid"=>"SMbce9fbb7a215f98319f37076628823bc", "FromState"=>"CA", "SmsStatus"=>"received", "FromCity"=>"EL CENTRO", "Body"=>"Hi", "FromCountry"=>"US", "To"=>"+17602354121", "ToZip"=>"92243", "NumSegments"=>"1", "MessageSid"=>"SMbce9fbb7a215f98319f37076628823bc", "AccountSid"=>"ACb71069e87d0ac594778e96b3b84464f7", "From"=>"+17602358826", "ApiVersion"=>"2010-04-01"}

    # if sms_count == 0
    #   message = "Welcome to HairsalonPro! Respond with '1' if you'd like find the nearest walk-in time.
    #   Respond with '2' if you'd like to make a future appointment"
    # else
    #   if params["Body"] == "1"
    #     message = "Yay! The nearest walk-in is at 2:00pm with Admin1. Respond
    #     with '1' if this works for you"
    #   elsif params["Body"] == "2"
    #     message = "Awesome! Please call XXX-XXX-XXXX to schedule an appointment.
    #     We currently only schedule walk-ins via text messaging"
    #   else        
    #     message = "#{params["Body"]} Hello, thanks for message number #{sms_count + 1}, #{session.keys}"
    #   end
    # end
    # case sms_count
    # when 0
    #   customer = Customer.find_by()
    #   if 
    # else
    # end

    response = Twilio::TwiML::Response.new do |r|
      r.Message message
    end
    session["counter"] = sms_count

    render_twiml response
  end

  def status
    render_twiml Twilio::TwiML::Response.new
  end
end