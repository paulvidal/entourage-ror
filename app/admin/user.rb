ActiveAdmin.register User do

  permit_params :email, :first_name, :last_name, :phone, :sms_code, :manager, :organization_id, :token, :device_type, :default_latitude, :default_longitude, coordinated_organization_ids: []

  active_admin_import

  form do |f|
    f.inputs
    f.inputs "Coordination of external organizations" do
      f.input :coordinated_organizations, as: :check_boxes, collection: Organization.where.not(id: :organization_id)
    end
    f.actions
  end
end
