# == Schema Information
#
# Table name: articles
#
#  id         :bigint           not null, primary key
#  body       :text
#  title      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_articles_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
require "rails_helper"

RSpec.describe Article, type: :model do
  context "必要な情報が揃っている時" do
    let(:user) { build(:user) }
    let(:article) { build(:article, user: user) }
    it "機材の作成に成功する" do
      expect(article).to be_valid
    end
  end

  context "body が入力されていない時" do
    let(:user) { build(:user) }
    let(:article) { build(:article, user: user, body: nil) }
    it "記事の作成に失敗する" do
      expect(article).to be_invalid
      expect(article.errors.details[:body][0][:error]).to eq :blank
    end
  end

  context "title が入力されていないとき" do
    let(:user) { build(:user) }
    let(:article) { build(:article, user: user, title: nil) }
    it "記事の作成に失敗する" do
      expect(article).to be_invalid
      expect(article.errors.details[:title][0][:error]).to eq :blank
    end
  end

  context "title が51文字以上の時" do
    let(:user) { build(:user) }
    let(:article) { build(:article, user: user, title: "a" * 51) }
    it "記事の作成に失敗する" do
      expect(article).to be_invalid
      expect(article.errors.messages[:title]).to eq ["is too long (maximum is 50 characters)"]
    end
  end
end
