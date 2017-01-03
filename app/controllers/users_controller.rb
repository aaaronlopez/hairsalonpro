class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
    @customers = Customer.all
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      flash[:success] = "You successfully created your own recipe!"
      redirect_to @user
    else
      flash[:danger] = @user.errors.full_messages.to_sentence
      redirect_to signup_path
    end
  end

  private
  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :phone_number, :password)
  end
end
