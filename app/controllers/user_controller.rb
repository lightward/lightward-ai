# frozen_string_literal: true

class UserController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = current_user

    render("user")
  end
end
