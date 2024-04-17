# Routes (routes.rb)
Rails.application.routes.draw do
  root "videos#new"
  
  resources :videos do
    get 'select_encrypted_video', on: :collection
    get 'decrypted_video/:id', to: 'videos#decrypted_video', as: 'decrypted_video', on: :collection
  end
  get "/service-worker.js", to: "service_worker#service_worker"
  get "/manifest.json", to: "service_worker#manifest"
end