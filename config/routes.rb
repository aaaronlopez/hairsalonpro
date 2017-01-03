Rails.application.routes.draw do
  devise_for :admins, controllers: { sessions: 'admins/sessions' }

  resources :admins
	resources :customers do
		resources :appointments
	end
  
  root 'static_pages#home'
  post 'twilio/voice' => 'twilio#voice'
  post 'twilio/receive_msg' => 'twilio#receive_msg'
  post 'twilio/status' => 'twilio#status'
  post 'notifications/notify' => 'notifications#notify'
end
