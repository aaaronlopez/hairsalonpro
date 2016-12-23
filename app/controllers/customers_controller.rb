class CustomersController < ApplicationController
  def show
    @customer = Customer.find(params[:id])
  end

  def new
  end

  def create
    @customer = Customer.new(customer_params)

    @customer.save
    redirect_to @customer
  end

  private
  def customer_params
    params.require(:customer).permit(:first_name, :last_name, :email, :phone_number)
  end
end
