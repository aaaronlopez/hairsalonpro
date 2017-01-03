class StaticPagesController < ApplicationController
  def home
  	if admin_signed_in?
  		redirect_to current_admin
  	else
  		render 'home'
  	end
  end
end
