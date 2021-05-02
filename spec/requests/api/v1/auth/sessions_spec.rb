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
        expect(response).to have_http_status(200)
      end
    end
    context "name が正しくない時" do
      let(:user) { create(:user) }
      let(:params) { { email: "test@sample.com", password: user.password } }
      fit "エラーする" do
        subject
        expect(response).to have_http_status(401)
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
        expect(response).to have_http_status(401)
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
end
