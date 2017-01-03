require 'twilio_sms'

class AppointmentsController < ApplicationController
  include TwilioSms

  def index
    @appointments = Appointment.all
  end

  def show
    @appointment = Appointment.find(params[:id])
  end

  def new
  end

  def create
    @appointment = Appointment.new(appointment_params)
    @appointment.customer_id = params[:customer_id]

    if @appointment.save
      # message = "Welcome to Hair Salon Pro, #{@appointment.first_name}! You have"\
      #   " been added as a appointment by #{@appointment.admin.first_name}.\n\nPlease"\
      #   " respond to this number at any time for any information or to make an"\
      #   " appointment."
      # media_url = "http://cliparting.com/wp-content/uploads/2016/06/Happy-face-"\
      #   "smiley-face-emotions-clip-art-images-image-7.jpg"
      # send_sms(TWILIO_NUMBER, @appointment.phone_number, message, media_url)

      flash[:notice] = "You successfully added a new appointment!"
      redirect_to @appointment.customer
    else
      flash[:error] = @appointment.errors.full_messages.to_sentence
      redirect_to new_customer_appointment_path
    end
  end

  def update
    @appointment = Appointment.find(params[:id])
   
    if @appointment.update(appointment_params)
      redirect_to @appointment
    else
      redirect_to edit_appointment_path
    end
  end

  def destroy
    @appointment = Appointment.find(params[:id])
    @appointment.destroy
 
    redirect_to appointments_path
  end

  private
    def appointment_params
      params.require(:appointment).permit(:start_time, :end_time)
    end
end
