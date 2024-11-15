# frozen_string_literal: true

class AdminController < ApplicationController
  def index
    if current_user&.admin?
      @users = User.pluck(:email, :created_at)
      render("admin")
    elsif current_user.nil?
      render("login")
    else
      raise ActionController::BadRequest
    end
  end
end
