ActiveRecord::Schema.define(:version => 1) do
  create_table :aqi_test_articles, :force => true do |t|
    t.integer :user_id
    t.string :name
  end
  
  add_index :aqi_test_articles, [:user_id, :name]
  
  create_table :aqi_test_users, :force => true do |t|
  end
end
