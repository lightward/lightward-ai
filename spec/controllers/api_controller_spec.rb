# frozen_string_literal: true

# spec/controllers/api_controller_spec.rb
require "rails_helper"

RSpec.describe(ApiController, :aggregate_failures) do
  describe ".budget_exceeded_message" do
    it "carries the base message, the when in human time, and a path to a human" do
      message = described_class.budget_exceeded_message(900)

      expect(message).to(start_with(ApiController::BUDGET_EXCEEDED_MESSAGE))
      expect(message).to(include("pick this back up in about 15 minutes."))
      expect(message).to(include("email team@lightward.com — a human reads these."))
    end

    it "omits the when if there is no retry window to name" do
      message = described_class.budget_exceeded_message(nil)

      expect(message).not_to(include("pick this back up"))
      expect(message).to(include("email team@lightward.com"))
    end
  end

  describe ".humanize_seconds" do
    it "speaks in minutes for short windows, rounding up" do
      expect(described_class.humanize_seconds(59)).to(eq("1 minute"))
      expect(described_class.humanize_seconds(61)).to(eq("2 minutes"))
      expect(described_class.humanize_seconds(900)).to(eq("15 minutes"))
      expect(described_class.humanize_seconds(89 * 60)).to(eq("89 minutes"))
    end

    it "speaks in hours from 90 minutes on" do
      expect(described_class.humanize_seconds(90 * 60)).to(eq("2 hours"))
      expect(described_class.humanize_seconds(3600 * 4)).to(eq("4 hours"))
      expect(described_class.humanize_seconds(86_400)).to(eq("24 hours"))
    end
  end
end
