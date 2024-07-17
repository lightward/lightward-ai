# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :authenticate_user!

  def show
    respond_to do |format|
      format.html
      format.json {
        render(json: current_user.as_json(
          only: [],
          methods: [:public_key_base64, :private_key_ciphertext, :salt_base64],
        ))
      }
    end
  end

  def update
    if current_user.update(user_params)
      respond_to do |format|
        format.html { redirect_to(account_path, notice: t(".success")) }
        format.json { render(json: { status: "success" }) }
      end
    else
      respond_to do |format|
        format.html { render(:show) }
        format.json { render(json: { status: "error", errors: current_user.errors }, status: :unprocessable_entity) }
      end
    end
  end

  private

  def user_params
    params.require(:user).permit(
      :public_key_base64,
      :private_key_ciphertext,
      :salt_base64,
    )
  end
end
