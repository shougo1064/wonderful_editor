require "rails_helper"

RSpec.describe "Api::V1::Auth::Sessions", type: :request do
  describe "POST /api/v1/auth/sign_in" do
    subject { post(api_v1_user_session_path, params: params) }

    context "メールアドレスとパスワードが正しい時" do
      let(:user) { create(:user) }
      let(:params) { { email: user.email, password: user.password } }
      it "ログインできる" do
        subject
        header = response.header
        expect(header["uid"]).to be_present
        expect(header["access-token"]).to be_present
        expect(header["client"]).to be_present
        expect(response).to have_http_status(:ok)
      end
    end

    context "name が正しくない時" do
      let(:user) { create(:user) }
      let(:params) { { email: "test@sample.com", password: user.password } }
      it "エラーする" do
        subject
        expect(response).to have_http_status(:unauthorized)
        res = JSON.parse(response.body)
        expect(res["success"]).to be_falsey
        expect(res["errors"]).to eq ["Invalid login credentials. Please try again."]
        header = response.header
        expect(header["uid"]).to be_blank
        expect(header["access-token"]).to be_blank
        expect(header["client"]).to be_blank
      end
    end

    context "password が正しくない時" do
      let(:user) { create(:user) }
      let(:params) { { email: user.email, password: "zzzzzzzz" } }
      it "エラーする" do
        subject
        expect(response).to have_http_status(:unauthorized)
        res = JSON.parse(response.body)
        expect(res["success"]).to be_falsey
        expect(res["errors"]).to eq ["Invalid login credentials. Please try again."]
        header = response.header
        expect(header["uid"]).to be_blank
        expect(header["access-token"]).to be_blank
        expect(header["client"]).to be_blank
      end
    end
  end

  describe "DELETE /api/v1/auth/sign_out" do
    subject { delete(destroy_api_v1_user_session_path, headers: headers) }

    context "ユーザーがログインしている時" do
      let(:user) { create(:user) }
      let!(:headers) { user.create_new_auth_token }
      it "ログアウトできる" do
        expect { subject }.to change { user.reload.tokens }.from(be_present).to(be_blank)
        expect(response).to have_http_status(:ok)
      end
    end

    context "誤った情報を送信した時" do
      let(:user) { create(:user) }
      let!(:headers) { { "uid": "", "access-token": "", "client": "" } }
      it "ログアウトできない" do
        subject
        expect(response).to have_http_status(:not_found)
        res = JSON.parse(response.body)
        expect(res["success"]).to be_falsey
        expect(res["errors"]).to eq ["User was not found or was not logged in."]
      end
    end
  end
end
