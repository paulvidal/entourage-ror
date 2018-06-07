class AddRoleToJoinRequests < ActiveRecord::Migration
  def up
    add_column :join_requests, :role, :string, limit: 8

    JoinRequest.joins(:tour).where("join_requests.user_id  = tours.user_id").update_all(role: :creator)
    JoinRequest.joins(:tour).where("join_requests.user_id != tours.user_id").update_all(role: :member)

    JoinRequest.joins(:entourage).where("community = 'entourage' and group_type = 'action' and join_requests.user_id  = entourages.user_id").update_all(role: :creator)
    JoinRequest.joins(:entourage).where("community = 'entourage' and group_type = 'action' and join_requests.user_id != entourages.user_id").update_all(role: :member)

    JoinRequest.joins(:entourage, :user).where("entourages.community = 'pfp' and group_type = 'private_circle' and users.roles @> '[\"visited\"]' and title = 'Les amis de ' || users.first_name").update_all(role: :visited)
    JoinRequest.joins(:entourage, :user).where("entourages.community = 'pfp' and group_type = 'private_circle' and role is null").update_all(role: :visited)

    change_column_null :join_requests, :role, false
  end
end
