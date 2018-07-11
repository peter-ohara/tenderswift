# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Contractor dashboard' do
  let(:tender) { FactoryBot.create(:tender) }
  let!(:different_contractor) { FactoryBot.create(:contractor) }
  let!(:request_for_tender) { FactoryBot.create(:request_for_tender) }
  let!(:purchased_tender) do
    FactoryBot.create(:purchased_tender, contractor: tender.contractor)
  end

  context 'when logged in' do
    background do
      login_as(tender.contractor, scope: :contractor)
    end

    scenario 'should show the contractor their private invitations to tender' do
      visit contractor_root_path
      puts page.body
      within :css, '#invitations-to-tender' do
        expect(page).to have_content request_for_tender.project_name
      end
    end

    scenario 'should show the contractor their purchased tender documents' do
      visit contractor_root_path
      within :css, '#purchased-tenders' do
        expect(page).to have_content purchased_tender.project_name
      end
    end

    scenario 'should show the contractor their submitted tender documents' do
      skip 'Spec not finished'
    end
  end

  context 'when logged out' do
    scenario 'should redirect the contractor to the login page' do
      visit contractor_root_path
      expect(page)
        .to have_content 'You need to sign in or sign up before continuing.'
      expect(page).to have_content 'Log in'
      expect(page).to have_field('contractor[email]')
      expect(page).to have_field('contractor[password]')
    end
  end

  context 'when another contractor logs in' do
    background do
      login_as(different_contractor, scope: :contractor)
    end

    scenario 'access another contractor bid' do
      visit tender_build_path(purchased_tender, :bill_of_quantities)
      expect(page).to have_content 'Home'
    end
  end
end
