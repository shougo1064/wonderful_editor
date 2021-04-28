# == Schema Information
#
# Table name: comments
#
#  id         :bigint           not null, primary key
#  body       :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  article_id :bigint           not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_comments_on_article_id  (article_id)
#  index_comments_on_user_id     (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (article_id => articles.id)
#  fk_rails_...  (user_id => users.id)
#
require "rails_helper"

RSpec.describe Comment, type: :model do
  context "コメントのbody が入力されている時" do
    let(:user) { build(:user) }
    let(:article) { build(:article, user: user) }
    let(:comment) { build(:comment, article: article) }
    it "コメントの投稿ができる" do
      expect(comment).to be_valid
    end
  end

  context "コメントのbody が入力されていない時" do
    let(:user) { build(:user) }
    let(:article) { build(:article, user: user) }
    let(:comment) { build(:comment, article: article, body: nil) }
    it "コメントの投稿に失敗する" do
      expect(comment).to be_invalid
      expect(comment.errors.messages[:body]).to eq ["can't be blank"]
    end
  end

  context "コメントの文字数が251文字以上の時" do
    let(:user) { build(:user) }
    let(:article) { build(:article, user: user) }
    let(:comment) { build(:comment, article: article, body: "a" * 251) }
    it "コメントの投稿に失敗する" do
      expect(comment).to be_invalid
      expect(comment.errors.messages[:body]).to eq ["is too long (maximum is 250 characters)"]
    end
  end
end
