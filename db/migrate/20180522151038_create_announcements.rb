class CreateAnnouncements < ActiveRecord::Migration
  def change
    create_table :announcements do |t|
      t.string :title, null: false
      t.string :body
      t.string :action
      t.integer :author_id
      t.string :avatar
      t.boolean :webview, null: false, default: true
      t.integer :position
      t.string :icon
      t.string :url
      t.string :status, null: false, default: 'inactive'
      t.timestamps
    end
  end
end
