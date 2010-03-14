ActiveRecord::Schema.define(:version => 1) do
  create_table :aqi_test_articles, :force => true do |t|
    t.integer :aqi_test_user_id
    t.string :name
  end
  
  add_index :aqi_test_articles, [:aqi_test_user_id, :name]
  
  create_table :aqi_test_users, :force => true do |t|
  end
end
