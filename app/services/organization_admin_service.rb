module OrganizationAdminService
  def self.remove_member author:, member:
    raise if author == member
    unless author.admin?
      raise unless author.partner_id == member.partner_id
      raise unless OrganizationAdmin::Permissions.can_remove_member?(author)
    end

    success = member.update(
      partner_id:         User.column_defaults['partner_id'],
      partner_admin:      User.column_defaults['partner_admin'],
      partner_role_title: User.column_defaults['partner_role_title'],
      targeting_profile:  User.column_defaults['targeting_profile'],
    )

    OrganizationAdmin::InvitationService.mark_accepted_invitations_as_outdated(
      user_id: member.id, partner_id: author.partner_id)

    success
  end
end
