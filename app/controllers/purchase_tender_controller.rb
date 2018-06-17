# frozen_string_literal: true

class PurchaseTenderController < ContractorsController
  before_action :set_request_for_tender, except: :complete_transaction

  before_action :set_policy

  skip_before_action :authenticate_contractor!, only: %i[
    portal
    purchase
    complete_transaction
  ]

  def portal
    authorize @request_for_tender

    tender = Tender.find_by(request_for_tender: @request_for_tender,
                            contractor: current_contractor)
    if tender&.purchased?
      redirect_to contractor_root_path,
                  notice: 'You have already purchased this tender'
    else
      increment_visit_count
      store_location_for(:contractor, request.fullpath)
    end
  end

  def purchase
    authorize @request_for_tender

    if current_contractor
      purchase_the_tender(current_contractor, @request_for_tender)
      return
    end

    contractor = Contractor.find_by(email: params[:email])

    if contractor&.valid_password?(params[:password])
      sign_in(:contractor, contractor)
      purchase_the_tender(current_contractor, @request_for_tender)
    elsif contractor && !contractor.valid_password?(params[:password])
      render 'require_password'
      return
    else
      contractor = Contractor.create!(email: params[:email],
                                      company_name: params[:company_name],
                                      phone_number: params[:customer_number],
                                      password: Devise.friendly_token.first(8))
      sign_in(:contractor, contractor)
      purchase_the_tender(current_contractor, @request_for_tender)
    end
  end

  def monitor_purchase
    authorize @request_for_tender

    @purchaser = RequestForTenderPurchaser.build(
      contractor: current_contractor,
      request_for_tender: @request_for_tender
    )

    if @purchaser.payment_success?
      flash[:notice] = 'You have purchased this tender successfully'
      flash.keep(:notice) # Keep flash notice around for the redirect.
      render js: "window.location = '#{contractor_root_path}'"
    elsif @purchaser.payment_failed?
      render 'purchase_tender_error'
    else
      render 'monitor_purchase'
    end
  end

  def complete_transaction
    authorize :purchase_tender, :complete_transaction?

    @purchaser = RequestForTenderPurchaser.build(
      contractor: nil,
      request_for_tender: nil
    )

    @purchaser.complete_transaction(complete_transaction_params)
    head :no_content
  end

  private

  def purchase_the_tender(contractor, request_for_tender)
    @purchaser = RequestForTenderPurchaser.build(
      contractor: contractor,
      request_for_tender: request_for_tender
    )
    if @purchaser.purchase(payment_params)
      render 'monitor_purchase'
    else
      render 'purchase_tender_error'
    end
  end

  def set_policy
    RequestForTender.define_singleton_method(:policy_class) do
      PurchaseTenderPolicy
    end
  end

  def increment_visit_count
    cookie_name = "request-for-tender-#{@request_for_tender.id}"
    return if cookies[cookie_name]

    @request_for_tender.portal_visits += 1
    @request_for_tender.save!
    cookies.permanent[cookie_name] = 'visited'
  end

  def set_request_for_tender
    @request_for_tender = RequestForTender.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to 'https://public.tenderswift.com/'
  end

  def payment_params
    params.permit(:network_code, :customer_number, :vodafone_voucher_code)
  end

  def complete_transaction_params
    params.permit(:transaction_id, :status, :message)
  end
end
