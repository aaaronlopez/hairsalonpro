require 'twilio_sms'

class CustomersController < ApplicationController
  include TwilioSms

  def index
    @customers = Customer.all
  end

  def show
    @customer = Customer.find(params[:id])
    @appointments = Appointment.where(customer: @customer)
  end

  def new
  end

  def edit
    @customer = Customer.find(params[:id])
  end

  def create
    @customer = Customer.new(customer_params)
    @customer.admin = current_admin

    if @customer.save
      message = "Welcome to Hair Salon Pro, #{@customer.first_name}! You have"\
        " been added as a customer by #{@customer.admin.first_name}.\n\nPlease"\
        " respond to this number at any time for any information"
      media_url = "http://cliparting.com/wp-content/uploads/2016/06/Happy-face-"\
        "smiley-face-emotions-clip-art-images-image-7.jpg"
      send_sms(TWILIO_NUMBER, @customer.phone_number, message, media_url)

      flash[:notice] = "You successfully added a new customer!"
      redirect_to @customer
    else
      flash[:error] = @customer.errors.full_messages.to_sentence
      redirect_to new_customer_path
    end
  end

  def update
    @customer = Customer.find(params[:id])
   
    if @customer.update(customer_params)
      redirect_to current_admin
    else
      redirect_to edit_customer_path
    end
  end

  def destroy
    @customer = Customer.find(params[:id])
    @customer.destroy
 
    redirect_to current_admin
  end

  private
    def customer_params
      params.require(:customer).permit(:first_name, :last_name, :phone_number)
    end
end
