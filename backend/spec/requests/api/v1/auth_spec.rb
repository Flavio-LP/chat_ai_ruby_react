require "rails_helper"

RSpec.describe "Api::V1::Auth", type: :request do
  describe "POST /api/v1/auth/sign_up" do
    let(:params) do
      {
        user: {
          name: "João Silva",
          email: "joao@example.com",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end

    it "creates a user and returns a JWT token" do
      post "/api/v1/auth/sign_up", params: params, as: :json

      expect(response).to have_http_status(:created)
      expect(response.parsed_body["token"]).to be_present
      expect(response.parsed_body.dig("user", "email")).to eq("joao@example.com")
    end

    it "returns errors for invalid data" do
      post "/api/v1/auth/sign_up",
        params: { user: { email: "invalid", password: "123" } },
        as: :json

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "POST /api/v1/auth/sign_in" do
    let!(:user) { create(:user, email: "joao@example.com", password: "password123") }

    it "returns a JWT token on valid credentials" do
      post "/api/v1/auth/sign_in",
        params: { user: { email: "joao@example.com", password: "password123" } },
        as: :json

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["token"]).to be_present
    end

    it "returns 401 on invalid credentials" do
      post "/api/v1/auth/sign_in",
        params: { user: { email: "joao@example.com", password: "wrong" } },
        as: :json

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "DELETE /api/v1/auth/sign_out" do
    it "signs out with a valid token" do
      user = create(:user)
      headers = auth_headers_for(user)

      delete "/api/v1/auth/sign_out", headers: headers

      expect(response).to have_http_status(:ok)
    end
  end
end
