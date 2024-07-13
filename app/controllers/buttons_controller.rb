# frozen_string_literal: true

# app/controllers/buttons_controller.rb

class ButtonsController < ApplicationController
  before_action :authenticate_user!

  def index
    @buttons = buttons.active
  end

  def index_archived
    @buttons = buttons.archived
  end

  def show
    @button = buttons.find(params[:id])
  end

  # GET /buttons/new
  def new
    @button = buttons.new
  end

  # POST /buttons
  def create
    @button = buttons.new(button_params)

    if @button.save
      redirect_to(@button, notice: t(:button_created))
    else
      render(:new)
    end
  end

  def archive
    @button = buttons.find(params[:id])
    @button.archive!
    redirect_to(buttons_path, notice: t(:button_archived))
  end

  def unarchive
    @button = buttons.find(params[:id])
    @button.unarchive!
    redirect_to(buttons_path, notice: t(:button_unarchived))
  end

  private

  def buttons
    current_user.buttons
  end

  def button_params
    params.require(:button).permit(:summary, :prompt, :archived, :user_id)
  end
end
