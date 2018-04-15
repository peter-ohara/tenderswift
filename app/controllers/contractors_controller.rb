# frozen_string_literal: true

class ContractorsController < ApplicationController
  before_action :set_contractor, only: %i[edit update]
  before_action :authenticate_contractor!

  def dashboard; end

  def edit; end

  def update
    respond_to do |format|
      if @contractor.update(contractor_params)
        format.html do
          redirect_to edit_contractor_path(@contractor),
                      notice: 'Your account information was changed successfully.'
        end
        format.json { render :edit, status: :ok, location: @contractor }
      else
        format.html { render :edit }
        format.json do
          render json: @contractor.errors,
                 status: :unprocessable_entity
        end
      end
    end
  end

  protected

  def pundit_user
    current_contractor
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_contractor
    @contractor = Contractor.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def contractor_params
    params.require(:contractor).permit(
      :full_name,
      :email,
      :phone_number,
      :company_name,
      :company_logo
    )
  end
end