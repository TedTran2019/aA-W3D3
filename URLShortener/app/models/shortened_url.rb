# == Schema Information
#
# Table name: shortened_urls
#
#  id         :bigint           not null, primary key
#  long_url   :string           not null
#  short_url  :string           not null
#  user_id    :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ShortenedUrl < ApplicationRecord
  validates :long_url, :short_url, :user_id, presence: true
  validates :short_url, uniqueness: true
  validate :no_spamming
  validate :nonpremium_max

  def self.prune(n)
    ShortenedUrl
    .joins(:submitter)
    .left_outer_joins(:visits)
    .where("shortened_urls.created_at <= ? AND users.premium = false", n.minutes.ago)
    .group("shortened_urls.id")
    .having("COALESCE(MAX(visits.created_at), ?) <= ?", n.hours.ago, n.minutes.ago)
    .select("shortened_urls.*")
    .destroy_all
  end

  def self.shorten(user, long_url)
    url = ShortenedUrl.new(:user_id => user.id, :long_url => long_url,
    :short_url => ShortenedUrl.random_code)
    url.save!
    url
  end

  def self.random_code
    code = nil
    until code
      code = SecureRandom::urlsafe_base64
      code = nil if ShortenedUrl.exists?(:short_url => code)
    end
    code
  end

  def num_clicks 
    visits.count
  end 

  def num_uniques 
    visitors.count
  end 

  def num_recent_uniques
    visitors
    .where("visits.created_at >= ?", 10.minutes.ago)
    .count(user_id)
  end

  def no_spamming
    recently_created = submitter.submitted_urls
    .where("shortened_urls.created_at >= ?", 1.minutes.ago)
    .count
    if recently_created > 4
      errors[:spam] << "5 shortened URLs max per minute!"
    end
  end 

  def nonpremium_max
    user = submitter
    return if user.premium == true

    submitted = user.submitted_urls.count
    if submitted > 4
      errors[:max] << "Non premium members can only have 5 URLs!"
    end
  end

  belongs_to :submitter, 
  foreign_key: :user_id, 
  class_name: :User

  has_many :visits,
  dependent: :destroy

  has_many :visitors, 
  -> { distinct },
  through: :visits, 
  source: :user

  has_many :taggings,
  foreign_key: :url_id,
  class_name: :Tagging,
  dependent: :destroy

  has_many :tag_topics,
  through: :taggings,
  source: :tag_topic
end
