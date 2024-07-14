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

  def new
    @button = buttons.new
  end

  def edit
    @button = buttons.find(params[:id])
  end

  def create
    @button = buttons.new(button_params)

    if @button.save
      redirect_to(@button, notice: t(".success"))
    else
      render(:new)
    end
  end

  def update
    @button = buttons.find(params[:id])

    if @button.update(button_params)
      redirect_to(@button, notice: t(".success"))
    else
      render(:edit)
    end
  end

  def archive
    @button = buttons.find(params[:id])
    @button.archive!
    redirect_to(buttons_path, notice: t(".success"))
  end

  def unarchive
    @button = buttons.find(params[:id])
    @button.unarchive!
    redirect_to(buttons_path, notice: t(".success"))
  end

  private

  def buttons
    current_user.buttons
  end

  def button_params
    params.require(:button).permit(:summary, :prompt, :archived, :user_id)
  end
end
