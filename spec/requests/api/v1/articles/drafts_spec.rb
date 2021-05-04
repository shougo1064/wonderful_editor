require 'rails_helper'

RSpec.describe "Api::V1::Articles::Drafts", type: :request do
  describe "GET /api/v1/articles/drafts" do
    subject { get(api_v1_articles_drafts_path, headers: headers) }
    let!(:article1) { create(:article, :draft, user: current_user, updated_at: 1.days.ago)}
    let!(:article2) { create(:article, :draft, user: current_user, updated_at: 2.days.ago)}
    let!(:article3) { create(:article, :draft, user: current_user) }
    let(:current_user) { create(:user) }
    let(:headers) { current_user.create_new_auth_token }
    fit "自分が書いた下書き記事の一覧が取得できる（更新順）" do
      subject
      res = JSON.parse(response.body)
      expect(res.length).to eq 3
      expect(res.map {|d| d["id"] }).to eq [article3.id, article1.id, article2.id]
      expect(res[0]["status"]).to eq "draft"
      expect(res[0]["user"]["id"]).to eq article1.user.id
      expect(res[0].keys).to eq ["id", "title", "updated_at", "status", "user"]
      expect(res[0]["user"].keys).to eq ["id", "name", "email"]
      expect(response).to have_http_status(:ok)
    end
  end
  describe "GET /api/v1/articles/drafts/:id" do
    subject { get(api_v1_articles_draft_path(article_id), headers: headers) }
    let(:headers) { current_user.create_new_auth_token }
    let(:current_user) { create(:user) }
    let(:article_id) { article.id }
    context "自分が書いた下書き記事の id を指定した時" do
      let(:article) { create(:article, :draft, user: current_user)}
      fit "指定した下書き記事の詳細が取得できる" do
        subject
        res = JSON.parse(response.body)
        expect(res["user"]["id"]).to eq article.user.id
        expect(res["id"]).to eq article.id
        expect(res["title"]).to eq article.title
        expect(res["body"]).to eq article.body
        expect(res["status"]).to eq "draft"
        expect(res["updated_at"]).to be_present
        expect(res["user"].keys).to eq ["id", "name", "email"]
        expect(response).to have_http_status(:ok)
      end
    end
    context "他人が書いた下書き記事の id を指定した時" do
      let(:article) { create(:article, :draft) }
      fit "その記事の詳細を取得できない" do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
