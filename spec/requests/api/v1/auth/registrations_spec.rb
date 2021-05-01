require "rails_helper"

RSpec.describe "Api::V1::Auth::Registrations", type: :request do
  describe "POST /api/v1/auth/registrations" do
    subject { post(api_v1_user_registration_path, params: params) }

    context "必要な情報を入力した時" do
      let(:params) { attributes_for(:user) }
      it "ユーザーの新規登録ができる" do
        expect { subject }.to change { User.count }.by(1)
        res = JSON.parse(response.body)
        expect(response).to have_http_status(:ok)
        expect(res["data"]["email"]).to eq(User.last.email)
      end

      it "ユーザーの header 情報が取得できる" do
        subject
        header = response.header
        expect(header["access-token"]).to be_present
        expect(header["token-type"]).to be_present
        expect(header["client"]).to be_present
        expect(header["expiry"]).to be_present
        expect(header["uid"]).to be_present
      end
    end

    context "name が存在しない時" do
      let(:params) { attributes_for(:user, name: nil) }
      it "エラーする" do
        expect { subject }.to change { User.count }.by(0)
        res = JSON.parse(response.body)
        expect(res["errors"]["name"]).to eq ["can't be blank"]
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "email が存在しない時" do
      let(:params) { attributes_for(:user, email: nil) }
      it "エラーする" do
        expect { subject }.to change { User.count }.by(0)
        res = JSON.parse(response.body)
        expect(res["errors"]["email"]).to eq ["can't be blank"]
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "password が存在しない時" do
      let(:params) { attributes_for(:user, password: nil) }
      it "エラーする" do
        expect { subject }.to change { User.count }.by(0)
        res = JSON.parse(response.body)
        expect(res["errors"]["password"]).to eq ["can't be blank"]
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
