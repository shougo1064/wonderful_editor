# == Schema Information
#
# Table name: articles
#
#  id         :bigint           not null, primary key
#  body       :text
#  status     :string           default("draft")
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
  context "必要なレコードが入力されている時" do
    let(:article) { build(:article) }
    it "下書き状態の記事が作成できる" do
      expect(article).to be_valid
      expect(article.status).to eq "draft"
    end
  end

  context "status が下書き状態のとき" do
    let(:article) { build(:article, :draft) }
    it "下書き状態の記事が作成できる" do
      expect(article).to be_valid
      expect(article.status).to eq "draft"
    end
  end

  context "status が公開状態のとき" do
    let(:article) { build(:article, :published) }
    it "公開状態の記事が作成できる" do
      expect(article).to be_valid
      expect(article.status).to eq "published"
    end
  end

  context "body が入力されていない時" do
    let(:user) { build(:user) }
    let(:article) { build(:article, user: user, body: nil) }
    it "記事が作成できない" do
      expect(article).to be_invalid
      expect(article.errors.details[:body][0][:error]).to eq :blank
    end
  end

  context "title が入力されていないとき" do
    let(:user) { build(:user) }
    let(:article) { build(:article, user: user, title: nil) }
    it "記事が作成できない" do
      expect(article).to be_invalid
      expect(article.errors.details[:title][0][:error]).to eq :blank
    end
  end

  context "title が51文字以上の時" do
    let(:user) { build(:user) }
    let(:article) { build(:article, user: user, title: "a" * 51) }
    it "記事が作成できない" do
      expect(article).to be_invalid
      expect(article.errors.messages[:title]).to eq ["is too long (maximum is 50 characters)"]
    end
  end
end
