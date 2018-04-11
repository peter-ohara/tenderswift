# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :quantity_surveyors
  devise_for :admins
  devise_for :contractors, path: 'contractors', controllers: {
    confirmations: 'contractors/confirmations',
    passwords: 'contractors/passwords',
    registrations: 'contractors/registrations',
    sessions: 'contractors/sessions',
    unlocks: 'contractors/unlocks'
  }

  root to: 'request_for_tenders#index'

  get '/tender/:id/edit', to: 'create_tender#edit_tender_information', as: 'edit_tender_information'
  patch '/tender/:id/update/project_information', to: 'create_tender#update_tender_information', as: 'update_tender_information'

  get '/tender/:id/edit/documents', to: 'create_tender#edit_tender_documents', as: 'edit_tender_documents'
  patch '/tender/:id/update/documents', to: 'create_tender#update_tender_documents', as: 'update_tender_documents'

  get '/tender/:id/edit/boq', to: 'create_tender#edit_tender_boq', as: 'edit_tender_boq'
  patch '/tender/:id/update/boq', to: 'create_tender#update_tender_boq', as: 'update_tender_boq'
  patch '/tender/:id/update/contract_sum_address', to: 'create_tender#update_contract_sum_address'

  get '/tender/:id/edit/required_documents', to: 'create_tender#edit_tender_required_documents', as: 'edit_tender_required_documents'
  patch '/tender/:id/update/required_documents', to: 'create_tender#update_tender_required_documents', as: 'update_tender_required_documents'

  get '/tender/:id/edit/payment_method', to: 'create_tender#edit_tender_payment_method', as: 'edit_tender_payment_method'
  patch '/tender/:id/update/payment_method', to: 'create_tender#update_tender_payment_method', as: 'update_tender_payment_method'
  patch '/payment/details/:id', to: 'create_tender#update_payment_details', as: 'update_payment_details'

  get '/tender/:id/edit/contractors', to: 'create_tender#edit_tender_contractors', as: 'edit_tender_contractors'
  patch '/tender/:id/update/contractors', to: 'create_tender#update_tender_contractors', as: 'update_tender_contractors'

  get '/projects/public/:id', to: 'request_for_tenders#portal', as: 'request_for_tender_portal'

  get '/tenders/:id', to: 'tenders#project_information', as: 'tenders_project_information'
  get '/tenders/:id/tender_documents', to: 'tenders#tender_documents', as: 'tenders_tender_documents'
  get '/tenders/:id/required_documents', to: 'tenders#required_documents', as: 'tenders_required_documents'
  get '/tenders/:id/boq', to: 'tenders#boq', as: 'tenders_boq'
  get '/tenders/:id/other/documents', to: 'tenders#other_documents', as: 'tender_other_documents'
  get '/tenders/:id/results', to: 'tenders#results', as: 'tenders_results'
  patch '/tenders/:id/rating', to: 'tenders#rating', as: 'tender_ratings'

  post '/sign_up_and_purchase/:id', to: 'contractors#sign_up_and_purchase', as: 'sign_up_and_purchase'

  post '/tenders/:id/required_document_uploads/', to: 'tenders#required_document_uploads', as: 'tenders_upload_required_documents'
  patch '/tenders/:id/other_document_uploads/', to: 'tenders#other_document_uploads', as: 'tender_other_documents_upload'
  post '/tenders/save_rates/:id/', to: 'tenders#save_rates'
  get '/tender/transactions/complete_transaction/', to: 'tender_transactions#complete_transaction', as: 'complete_transaction'

  get '/bids/:id', to: 'bids#required_documents', as: 'bid_required_documents'
  get '/bids/:id/boq', to: 'bids#boq', as: 'bid_boq'
  get '/bids/:id/other_documents', to: 'other_document_uploads#other_documents', as: 'bid_other_documents'

  get '/bids/:id/pdf_viewer/:required_document_upload_id', to: 'bids#pdf_viewer', as: 'view_pdf'
  get '/bids/:id/image_viewer/:required_document_upload_id', to: 'bids#image_viewer', as: 'view_image'
  get '/bids/:id/pdf_viewer/other/:other_document_id', to: 'other_document_uploads#pdf_viewer', as: 'view_pdf_for_other_documents'
  get '/bids/:id/image_viewer/other/:other_document_id', to: 'other_document_uploads#image_viewer', as: 'view_image_for_other_documents'

  get '/request_for_tenders/:id/compare_boq', to: 'request_for_tenders#compare_boq', as: 'compare_boq'

  patch '/bids/update/:required_document_upload_id', to: 'bids#update', as: 'update_bid'
  patch '/bids/update/other/:other_document_id', to: 'other_document_uploads#update', as: 'update_other_document'
  post '/bids/disqualify/:id/', to: 'bids#disqualify', as: 'disqualify_bid'
  post '/bids/undo_disqualify/:id/', to: 'bids#undo_disqualify', as: 'undo_disqualify_bid'
  post '/bids/rate/:id/', to: 'bids#rate', as: 'rate_bid'

  get '/contractors/dashboard', to: 'contractors#dashboard', as: 'contractors_dashboard'

  resources :quantity_surveyors, only: %i[edit update]
  resources :contractors, only: %i[new create edit update]
  resources :request_for_tenders
  resources :tenders
  resources :tender_transactions, only: %i[create update]

  mount RailsAdmin::Engine => '/adonai', as: 'rails_admin'

  mount ActionCable.server => '/cable'
end
