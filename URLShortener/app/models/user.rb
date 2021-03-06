# == Schema Information
#
# Table name: users
#
#  id         :bigint           not null, primary key
#  email      :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  premium    :boolean          default(FALSE), not null
#

class User < ApplicationRecord
  validates :email, :premium, presence: true
  validates :email, uniqueness: true
  
  has_many :submitted_urls,
  foreign_key: :user_id, 
  class_name: :ShortenedUrl

  has_many :visits

  has_many :visited_urls,
  -> { distinct },
  through: :visits, 
  source: :shortened_url
end
