class Post < ActiveRecord::Base
  belongs_to :creator, foreign_key: 'user_id', class_name: 'User'
  has_many :comments
  has_many :categories_posts
  has_many :categories, :through => :categories_posts
end
