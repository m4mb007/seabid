require 'rails_helper'

RSpec.describe "Bids", type: :request do
  describe "GET /create" do
    it "returns http success" do
      get "/bids/create"
      expect(response).to have_http_status(:success)
    end
  end

end
