class StaticPagesController < ApplicationController
  def home
    if admin_signed_in?
      redirect_to current_admin
    else
      redirect_to new_admin_session_path
    end
  end
end
