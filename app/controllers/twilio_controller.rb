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
          " Respond with '1' if you'd like to see your current appointments.\n"\
          " Respond with '2' if you'd like to make a walk-in appointment today.\n"
      else
        message = "Welcome to Hair Salon Pro, #{params["From"]}! We do not have"\
          " your number on record. Would you like to be added as a customer?\n\n"\
          " Respond with 'yes' or 'no'."
      end
      sms_count += 1
    when 1
      if customer
        # #TODO: modularize this
        # day = Time.now # adding number of seconds in day
        # day_start = Time.new(day.year, day.month, day.day, 8, 0, 0).iso8601
        # day_end = Time.new(day.year, day.month, day.day, 16, 0, 0).iso8601
        # events_by_day = list_events_by_time(day_start, day_end)
        # curr_appointments = []
        # events_by_day.each do |event|
        #   curr_appointments.push([event[0].hour, event[1].hour])
        # end
        # results = []
        # for i in 8..15
        #   results.push([i, i + 1])
        # end
        # new_appointments = results - curr_appointments
        if response == "1"
          curr_appointments = Appointment.where(customer_id: customer.id)
          if curr_appointments
            message = "Here are your current appointments:\n"
            curr_appointments.each do |appt|
              message += "* #{appt.start_time.strftime('%A, %B %d at %I:%M %p')}\n"
            end
          else
            message = "You currently do not have any appointments scheduled."
          end

        elsif response = "2"

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