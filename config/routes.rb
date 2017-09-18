Rails.application.routes.draw do
  resources :messages
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  root to: 'welcome#index'

  get '/email_request_for_tender/:id',
      to: 'request_for_tenders#email_request_for_tender',
      as: 'email_request_for_tender'

  get '/show_interest_in_request_for_tender/:id',
      to: 'participants#show_interest_in_request_for_tender',
      as: 'show_interest_in_request_for_tender'

  get '/show_disinterest_in_request_for_tender/:id',
      to: 'participants#show_disinterest_in_request_for_tender',
      as: 'show_disinterest_in_request_for_tender'

  get '/participants/:id/boq',
      to: 'participants#show_boq',
      as: 'participant_boq'

  devise_for :quantity_surveyors

  resources :items
  resources :sections
  resources :pages
  resources :request_for_tenders
  resources :boqs
  resources :participants
  resources :filled_items
  resources :broadcast_messages
  resources :chatrooms
  resources :countries
  resources :tags

  mount ActionCable.server => '/cable'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
