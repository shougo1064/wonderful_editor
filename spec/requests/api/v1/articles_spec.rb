require "rails_helper"

RSpec.describe "Api::V1::Articles", type: :request do
  describe "GET /api/v1/articles" do
    subject { get(api_v1_articles_path) }

    let!(:article1) { create(:article, :published, updated_at: 1.days.ago) }
    let!(:article2) { create(:article, :published, updated_at: 2.days.ago) }
    let!(:article3) { create(:article, :published) }
    let!(:article4) { create(:article, :draft) }
    it "公開済みの記事の一覧が取得できる（更新順）" do
      subject
      res = JSON.parse(response.body)
      expect(res.length).to eq 3
      expect(res.map {|d| d["id"] }).to eq [article3.id, article1.id, article2.id]
      expect(res[0]["status"]).to eq "published"
      expect(res[0].keys).to eq ["id", "title", "updated_at", "status", "user"]
      expect(res[0]["user"].keys).to eq ["id", "name", "email"]
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /api/v1/articles/:id" do
    subject { get(api_v1_article_path(article_id)) }

    context "公開状態の記事の id を指定した時" do
      let(:article_id) { article.id }
      let(:article) { create(:article, :published) }
      it "指定したidの公開記事のレコードが返ってくる" do
        subject
        res = JSON.parse(response.body)
        expect(res["id"]).to eq article.id
        expect(res["title"]).to eq article.title
        expect(res["updated_at"]).to be_present
        expect(res["status"]).to eq "published"
        expect(res["user"].keys).to eq ["id", "name", "email"]
        expect(response).to have_http_status(:ok)
      end
    end

    context "下書き状態の記事のidを指定した時" do
      let(:article_id) { article.id }
      let(:article) { create(:article) }
      it "エラーする" do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "存在しない記事の id を指定した時" do
      let(:article_id) { 100000 }
      it "記事のレコードが見つからない" do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "POST /api/v1/articles" do
    subject { post(api_v1_articles_path, params: params, headers: headers) }

    context "適切なパラメータを送信した時" do
      let(:params) { { article: attributes_for(:article) } }
      let(:current_user) { create(:user) }
      let(:headers) { current_user.create_new_auth_token }
      it "下書き記事が作成される" do
        expect { subject }.to change { Article.count }.by(1)
        res = JSON.parse(response.body)
        expect(res["status"]).to eq "draft"
        expect(res["title"]).to eq params[:article][:title]
        expect(res["body"]).to eq params[:article][:body]
        expect(res["user"]["id"]).to eq current_user.id
        expect(response).to have_http_status(:ok)
      end
    end

    context "記事の状態を公開に指定して適切なパラメータを送信したとき" do
      let(:params) { { article: attributes_for(:article, :published) } }
      let(:current_user) { create(:user) }
      let(:headers) { current_user.create_new_auth_token }
      it "公開記事が作成される" do
        expect { subject }.to change { Article.count }.by(1)
        res = JSON.parse(response.body)
        expect(res["status"]).to eq "published"
        expect(res["title"]).to eq params[:article][:title]
        expect(res["body"]).to eq params[:article][:body]
        expect(res["user"]["id"]).to eq current_user.id
        expect(response).to have_http_status(:ok)
      end
    end

    context "不適切なパラメータを送信した時" do
      let(:params) { attributes_for(:article) }
      let(:current_user) { create(:user) }
      let(:headers) { current_user.create_new_auth_token }
      it "記事作成に失敗する" do
        expect { subject }.to raise_error(ActionController::ParameterMissing)
      end
    end
  end

  describe "PATCH /api/v1/articles/:id" do
    subject { patch(api_v1_article_path(article_id), params: params, headers: headers) }

    let(:article_id) { article.id }
    let(:current_user) { create(:user) }
    let(:headers) { current_user.create_new_auth_token }
    let(:params) {  { article: { title: "foo", created_at: 1.days.ago, status: "published" } } }
    context "下書き状態で自分の記事を更新しようとするとき" do
      let!(:article) { create(:article, :draft, user: current_user) }
      it "下書き状態で記事が更新できる" do
        expect { subject }.to change { article.reload.title }.from(article.title).to(params[:article][:title]) &
                              not_change { article.reload.body } &
                              not_change { article.reload.created_at } &
                              change { article.reload.status }.from(article.status).to(params[:article][:status])
      end
    end

    context "他のユーザーの記事を更新しようとるすとき" do
      let(:other_user) { create(:user) }
      let!(:article) { create(:article, user: other_user) }

      it "更新できない" do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
        change { Article.count }.by(0)
      end
    end
  end

  describe "DELETE /api/v1/articles/:id" do
    subject { delete(api_v1_article_path(article_id), headers: headers) }

    let(:article_id) { article.id }
    let(:current_user) { create(:user) }
    let(:headers) { current_user.create_new_auth_token }

    context "自分が作成した記事を削除するとき" do
      let!(:article) { create(:article, user: current_user) }
      it "記事が削除できる" do
        expect { subject }.to change { Article.count }.by(-1)
        expect(response).to have_http_status(:no_content)
      end
    end

    context "他のユーザーの記事を削除しようとする時" do
      let!(:article) { create(:article, user: other_user) }
      let(:other_user) { create(:user) }
      it "エラーする" do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
