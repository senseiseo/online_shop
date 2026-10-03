# frozen_string_literal: true

require "rails_helper"

# rubocop:disable RSpec/MultipleExpectations
RSpec.describe "Visitor identification", type: :request do
  it "creates a visitor and a signed opaque cookie" do
    expect { get root_path }.to change(Visitor, :count).by(1)

    visitor = Visitor.last
    expect(visitor).to have_attributes(first_seen_at: be_present, last_seen_at: be_present)
    expect(response.cookies["visitor_token"]).not_to include(visitor.token)
  end

  it "reuses a valid visitor cookie and updates last_seen_at" do
    get root_path
    visitor = Visitor.last
    visitor.update_column(:last_seen_at, 1.day.ago)

    expect { get root_path }.not_to change(Visitor, :count)

    expect(visitor.reload.last_seen_at).to be > 1.minute.ago
  end

  it "replaces an invalid cookie with an isolated visitor" do
    cookies[:visitor_token] = "tampered"

    expect { get root_path }.to change(Visitor, :count).by(1)
    expect(Visitor.last.token).not_to eq("tampered")
  end
end
# rubocop:enable RSpec/MultipleExpectations
