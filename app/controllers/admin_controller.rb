# frozen_string_literal: true

class AdminController < ApplicationController
  def index
    if current_user&.admin?
      @users = User.order(created_at: :desc)

      if params[:subscribers]
        @users = @users.subscribers
      end

      render("admin")

    elsif current_user.nil?
      render("login")
    else
      raise ActionController::BadRequest
    end
  end
end
