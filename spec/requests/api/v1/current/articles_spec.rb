require "rails_helper"

RSpec.describe "Api::V1::Current::Articles", type: :request do
  describe "GET /api/v1/current/articles" do
    subject { get(api_v1_current_articles_path, headers: headers) }

    let(:headers) { current_user.create_new_auth_token }
    let(:current_user) { create(:user) }
    let!(:article1) { create(:article, :published, updated_at: 1.days.ago, user: current_user) }
    let!(:article2) { create(:article, :published, user: current_user) }
    let!(:article3) { create(:article, :draft, user: current_user) }
    let!(:article4) { create(:article, :published) }
    it "自分が書いた公開状態の記事の一覧が取得できる（更新順）" do
      subject
      res = JSON.parse(response.body)
      expect(res.length).to eq 2
      expect(res.map {|d| d["id"] }).to eq [article2.id, article1.id]
      expect(res[0]["status"]).to eq "published"
      expect(res[0]["user"]["id"]).to eq article1.user.id
      expect(response).to have_http_status(:ok)
      expect(res[0].keys).to eq ["id", "title", "updated_at", "status", "user"]
      expect(res[0]["user"].keys).to eq ["id", "name", "email"]
    end
  end
end
