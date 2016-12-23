class AdminsController < ApplicationController
  def show
    @admin = Admin.find(params[:id])
  end

  def new
  end

  def create
    @admin = Admin.new(admin_params)

    @admin.save
    redirect_to @admin
  end

  private
  def admin_params
    params.require(:admin).permit(:first_name, :last_name, :email, :phone_number)
  end
end
