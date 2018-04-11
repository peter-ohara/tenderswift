# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Contractor can purchase invitation_to_tender' do
  let!(:invitation_to_tender) { FactoryBot.create(:request_for_tender) }
  let!(:contractor) { FactoryBot.build(:contractor) }

  scenario 'as a new user' do
    visit request_for_tender_portal_path(invitation_to_tender)

    fill_in 'Company name', with: contractor.company_name
    fill_in 'Phone number', with: contractor.phone_number
    fill_in 'Email', with: contractor.email
    fill_in 'Password', with: contractor.password

    select 'MTN Mobile Money', from: :network_code
    fill_in :customer_number, with: contractor.phone_number
    fill_in :vodafone_voucher_code, with: '123456'

    click_button 'Sign up and Purchase'

    should_find_request_for_tender_in_purchased_tenders

    click_link invitation_to_tender.project_name

    should_have_invitation_to_tender_content
  end

  scenario 'when they already have an account' do
  end

  scenario 'when they are already signed in' do
  end


  private

  def should_find_request_for_tender_in_purchased_tenders
    purchased_tenders_container = page.find('#purchased-tenders')
    expect(purchased_tenders_container).to have_content invitation_to_tender.project_name
  end

  def should_have_invitation_to_tender_content
    expect(page).to have_content invitation_to_tender.project_name
    expect(page).to have_content invitation_to_tender.project_owners_company_name
    expect(page).to have_content invitation_to_tender.contract_class
    expect(page).to have_content invitation_to_tender.project_location
    expect(page).to have_content invitation_to_tender.project_currency

    expect(page).to have_content invitation_to_tender.time_to_deadline
    expect(page).to have_content invitation_to_tender.project_deadline.to_formatted_s(:long)

    expect(page).to have_content invitation_to_tender.project_description

    invitation_to_tender.required_documents.each do |required_document|
      expect(page).to have_content required_document.title
    end

    expect(page).to have_content invitation_to_tender.tender_instructions
  end
end
