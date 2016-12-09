class RemovedDeviceColumnsToUsers < ActiveRecord::Migration
  def up
     remove_column :users, :device_id
     remove_column :users, :device_type
   end

   def down
     add_column :users, :device_id
     add_column :users, :device_type
   end
end
