require 'twilio_sms'
require 'google_calendar'

class AppointmentsController < ApplicationController
  include TwilioSms
  include GoogleCalendar

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
      summary = "Hair Cut - #{@appointment.customer.first_name}"
      event = insert_calendar_event(@appointment.start_time.strftime('%Y-%m-%dT%H:%M:%S'),
        @appointment.end_time.strftime('%Y-%m-%dT%H:%M:%S'), summary, OFFICE_ADDRESS)
      @appointment.event_id = event.id
      @appointment.save

      message = "Hi #{@appointment.customer.first_name}! You have an appointment with Hair"\
        " Salon Pro on #{@appointment.start_time.strftime('%A, %B %d at %I:%M %p')}."\
        " We hope to see you soon! #{event.html_link}"
      send_sms(TWILIO_NUMBER, @appointment.customer.phone_number, message, nil)

      flash[:notice] = "You successfully added a new appointment!"
      redirect_to @appointment.customer
    else
      flash[:error] = @appointment.errors.full_messages.to_sentence
      redirect_to new_customer_appointment_path
    end
  end

  def update
    # TODO: add new send_sms() here to show changed appointment
    @appointment = Appointment.find(params[:id])
   
    if @appointment.update(appointment_params)
      redirect_to customer_path(@customer)
    else
      redirect_to edit_appointment_path
    end
  end

  def destroy
    # TODO: add event_id to appointment table and delete from Google Calendar
    @appointment = Appointment.find(params[:id])
    message = "Hi #{@appointment.customer.first_name}! Your appointment with Hair"\
        " Salon Pro on #{@appointment.start_time.strftime('%A, %B %d at %I:%M %p')}"\
        " has been CANCELLED. EVENT_ID: #{@appointment.event_id}"
    send_sms(TWILIO_NUMBER, @appointment.customer.phone_number, message, nil)

    #delete_calendar_event(@appointment.event_id)
    @appointment.destroy
 
    redirect_to customer_path(@appointment.customer)
  end

  private
    def appointment_params
      params.require(:appointment).permit(:start_time, :end_time, :event_id)
    end
end
