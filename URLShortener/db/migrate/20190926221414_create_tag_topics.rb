class CreateTagTopics < ActiveRecord::Migration[6.0]
  def change
    create_table :tag_topics do |t|
      t.string :topic, null: false
      t.timestamps
    end

    add_index :tag_topics, :topic
  end
end
