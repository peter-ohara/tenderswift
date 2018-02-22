class ParticipantsController < ApplicationController
  before_action :set_participant, only: %i[update destroy
                                           project_information
                                           boq
                                           questionnaire
                                           tender_document
                                           results
                                           show_boq
                                           disqualify undo_disqualify rate]

  include TenderTransactionsHelper

  include ApplicationHelper

  def messages; end

  def project_information
    @tender_transaction = TenderTransaction.new
  end

  def boq
    @tender_transaction = TenderTransaction.new
  end

  def questionnaire
    @tender_transaction = TenderTransaction.new
    @request = @participant.request_for_tender
    @required_document_upload = RequiredDocumentUpload.new
    @request.required_documents.each { @participant.required_document_uploads.build }
    @participant.request_for_tender.required_documents.each do |required_document|
      required_document_upload = @participant.required_document_upload_for(required_document)
    end
  end

  def tender_document
    @request = @participant.request_for_tender
  end

  def results; end

  # POST /participants
  # POST /participants.json
  def create
    @participant = Participant.new(participant_params)

    respond_to do |format|
      if @participant.save
        format.html { redirect_to @participant, notice: 'Participant was successfully created.' }
        format.json { render :show, status: :created, location: @participant }
      else
        format.html { render :new }
        format.json { render json: @participant.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /participants/1
  # PATCH/PUT /participants/1.json
  def update
    respond_to do |format|
      if @participant.update(participant_params)
        format.html do
          if params[:commit] == 'save_rating'
            redirect_to bid_boq_path(@participant), notice: 'Participant was successfully updated.'
          else
            redirect_to @participant, notice: 'Participant was successfully updated.'
          end
        end
        format.json { render :show, status: :ok, location: @participant }
      else
        format.html { render :edit }
        format.json { render json: @participant.errors, status: :unprocessable_entity }
      end
    end
  end

  def disqualify
    if @participant.update(disqualified: true)
      redirect_back fallback_location: bid_boq_path(@participant),
                    notice: "#{@participant.company_name} has been disqualified"
    else
      redirect_back fallback_location: root_path,
                    notice: "An error occurred while trying to disqualify #{@participant.company_name}"
    end
  end

  def undo_disqualify
    if @participant.update(disqualified: false)
      redirect_back fallback_location: bid_boq_path(@participant),
                    notice: "#{@participant.company_name} has been re-added to the shortlist"
    else
      redirect_back fallback_location: bid_boq_path(@participant),
                    notice: "An error occurred while trying to re-add #{@participant.company_name} to shortlist"
    end
  end

  def rate
    if @participant.update(rating: params[:rating])
      redirect_back fallback_location: bid_boq_path(@participant),
                    notice: "The rating for #{@participant.company_name} has been updated"
    else
      redirect_back fallback_location: bid_boq_path(@participant),
                    notice: "An error occurred while trying to update the rating for #{@participant.company_name}"
    end
  end

  # DELETE /participants/1
  # DELETE /participants/1.json
  def destroy
    @participant.destroy
    respond_to do |format|
      format.html { redirect_to participants_url, notice: 'Participant was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def pay_public_tender
    @participant = Participant.new(email: params[:participant][:email],
                                   company_name: params[:participant][:company_name],
                                   phone_number: params[:participant][:phone_number])
    @participant.request_for_tender_id = params[:participant][:request_for_tender_id]
    @participant.purchase_time = Time.current
    @participant.save!
    payload = extract_payload(params[:participant][:tender_transaction_attributes],
                              params[:participant][:request_for_tender_id])
    json_document = get_json_document(payload)
    puts payload
    authorization_string = hmac_auth(json_document)
    params[:participant][:tender_transaction_attributes][:participant_id] = @participant.id
    puts params[:participant][:tender_transaction_attributes]
    results = TenderTransaction.make_payment(authorization_string, payload,
                                                 params[:participant][:tender_transaction_attributes][:customer_number],
                                                 params[:participant][:tender_transaction_attributes][:amount],
                                                 params[:participant][:tender_transaction_attributes][:vodafone_voucher_code],
                                                 params[:participant][:tender_transaction_attributes][:network_code],
                                                 params[:participant][:tender_transaction_attributes][:status],
                                                 @participant.id,
                                                 @participant.request_for_tender.id,
                                                 payload['transaction_id'])
    if !results.nil? && working_url?(results)
      flash[:notice] = "Visit #{view_context.link_to('here in', results)}
                        another tab to finish the paying with VISA/MASTER CARD.
                        After paying come back and refresh this page."
    else
      flash[:notice] = results + '. Refresh this page after responding to the
                                   prompt on your phone. Thank you!'
    end
    redirect_to participants_questionnaire_url @participant
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_participant
    if params[:id].first(6) == 'guest-'
      request_for_tender = RequestForTender.find(params[:id][6..-1])
      @participant = GuestParticipant.new(request_for_tender)
      @request = request_for_tender
    else
      @participant = Participant.find_by(auth_token: params[:id])
      @request = @participant.request_for_tender
    end
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def participant_params
    params.require(:participant)
          .permit(:request_for_tender_id,
                  :company_name,
                  :phone_number,
                  :email,
                  :rating,
                  :purchased,
                  :submitted,
                  :purchase_time,
                  :submitted_time,
                  :read,
                  :rating,
                  :disqualified,
                  :notes,
                  tender_transaction_attributes: %i[id
                                                    customer_number
                                                    amount
                                                    transaction_id
                                                    vodafone_voucher_code
                                                    network_code
                                                    status
                                                    request_for_tender_id],
                  other_document_uploads_attributes: %i[id
                                                        document
                                                        _destroy],
                  required_document_uploads_attributes: %i[id
                                                           document
                                                           _destroy])
  end
end
