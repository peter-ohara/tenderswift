# frozen_string_literal: true

class WelcomeController < ApplicationController
  layout 'request_for_tenders'

  def index
    if current_quantity_surveyor
      redirect_to quantity_surveyor_root_path
    elsif current_contractor
      redirect_to quantity_surveyor_root_path
    else
      redirect_to 'https://www.tenderswift.com'
    end
  end

  def query_request_for_tender
  end

  def find_request_for_tender
    begin
      @search_result = RequestForTender.find(params[:reference_number])
      redirect_to purchase_tender_url(@search_result)
    rescue ActiveRecord::RecordNotFound
      flash[:notice] = 'No request for tender was not found'
      redirect_to query_request_for_tender_url
      return
    end
  end
end
