# frozen_string_literal: true

require "rails_helper"

RSpec.describe User, type: :model do
  it "defaults staff to admin" do
    expect(build(:user)).to be_admin
  end

  it "defines the staff roles" do
    expect(described_class.roles).to eq("admin" => 0, "editor" => 1, "manager" => 2)
  end
end
