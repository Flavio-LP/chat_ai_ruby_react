require "rails_helper"

RSpec.describe "Api::V1::Conversations", type: :request do
  let(:user) { create(:user) }
  let(:headers) { auth_headers_for(user) }

  describe "GET /api/v1/conversations" do
    it "returns conversations for the authenticated user" do
      create_list(:conversation, 3, user: user)
      create(:conversation)

      get "/api/v1/conversations", headers: headers

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["conversations"].length).to eq(3)
    end

    it "returns 401 without token" do
      get "/api/v1/conversations"
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "POST /api/v1/conversations" do
    let(:params) { { conversation: { title: "Nova conversa" } } }

    it "creates a conversation" do
      post "/api/v1/conversations", params: params, headers: headers, as: :json

      expect(response).to have_http_status(:created)
      expect(response.parsed_body.dig("conversation", "title")).to eq("Nova conversa")
    end

    it "copies system prompt content when system_prompt_id is provided" do
      prompt = create(:system_prompt, user: user, content: "Seja conciso.")

      post "/api/v1/conversations",
        params: params.merge(system_prompt_id: prompt.id),
        headers: headers, as: :json

      expect(response).to have_http_status(:created)
      expect(response.parsed_body.dig("conversation", "system_prompt_content")).to eq("Seja conciso.")
    end

    it "does not allow accessing another user's prompt" do
      other_prompt = create(:system_prompt, content: "Conteúdo privado.")

      post "/api/v1/conversations",
        params: params.merge(system_prompt_id: other_prompt.id),
        headers: headers, as: :json

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "DELETE /api/v1/conversations/:id" do
    it "destroys the conversation" do
      conversation = create(:conversation, user: user)

      delete "/api/v1/conversations/#{conversation.id}", headers: headers

      expect(response).to have_http_status(:no_content)
      expect(Conversation.find_by(id: conversation.id)).to be_nil
    end

    it "returns 404 for another user's conversation" do
      other_conversation = create(:conversation)

      delete "/api/v1/conversations/#{other_conversation.id}", headers: headers

      expect(response).to have_http_status(:not_found)
    end
  end
end
