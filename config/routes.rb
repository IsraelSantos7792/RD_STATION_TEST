require 'sidekiq/web'

if Rails.env.production?
  Sidekiq::Web.use(Rack::Auth::Basic) do |username, password|
    ActiveSupport::SecurityUtils.secure_compare(username, ENV.fetch("SIDEKIQ_WEB_USERNAME", "")) &
      ActiveSupport::SecurityUtils.secure_compare(password, ENV.fetch("SIDEKIQ_WEB_PASSWORD", ""))
  end
end

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'
  resources :products
  get "up" => "rails/health#show", as: :rails_health_check

  root "rails/health#show"

  get "/cart", to: "carts#show"
  post "/cart", to: "carts#create"
  delete "/cart", to: "carts#destroy"
  post "/cart/add_item", to: "carts#add_item"
  delete "/cart/:product_id", to: "carts#remove_item"
end
