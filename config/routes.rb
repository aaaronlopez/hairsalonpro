Rails.application.routes.draw do
  resources :admins
  resources :customers

  post 'twilio/voice' => 'twilio#voice'
  post 'twilio/receive_msg' => 'twilio#receive_msg'
  post 'twilio/status' => 'twilio#status'
  post 'notifications/notify' => 'notifications#notify'
end
