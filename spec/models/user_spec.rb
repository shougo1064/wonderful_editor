require "rails_helper"

RSpec.describe User, type: :model do
  context "必要な情報が全て揃っている時" do
    let(:user) { build(:user) }
    it "ユーザーの作成に成功する" do
      expect(user).to be_valid
    end
  end

  context "name が入力されていないとき" do
    let(:user) { build(:user, name: nil) }
    it "ユーザーの作成に失敗する" do
      expect(user).to be_invalid
      expect(user.errors.details[:name][0][:error]).to eq :blank
    end
  end

  context "name だけ入力されている時" do
    let(:user) { build(:user, email: nil, password: nil) }
    it "ユーザーの作成に失敗する" do
      expect(user).to be_invalid
      expect(user.errors.details[:password][0][:error]).to eq :blank
      expect(user.errors.details[:email][0][:error]).to eq :blank
    end
  end

  context "すでに同じ名前のユーザーが存在するとき" do
    let(:user) { build(:user, name: "foo") }
    it "ユーザーの作成に失敗する" do
      create(:user, name: "foo")
      expect(user).to be_invalid
      expect(user.errors.details[:name][0][:error]).to eq :taken
    end
  end
end
