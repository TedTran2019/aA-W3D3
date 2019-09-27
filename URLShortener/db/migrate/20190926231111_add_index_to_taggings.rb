class AddIndexToTaggings < ActiveRecord::Migration[6.0]
  def change
    add_index :taggings, [:tag_topic_id, :url_id], unique: true
  end
end
