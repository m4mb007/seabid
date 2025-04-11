require 'rails_helper'

RSpec.describe "PlateNumbers", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/plate_numbers/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/plate_numbers/show"
      expect(response).to have_http_status(:success)
    end
  end

end
