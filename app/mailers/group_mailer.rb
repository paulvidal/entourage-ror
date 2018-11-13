class GroupMailer < MailjetMailer
  #
  # Group created
  #

  def action_confirmation action
    action_creator = action.user

    mailjet_email(
      to: action_creator,
      campaign_name: :action_confirmation,
      template_id: 312279,
      variables: [
        :first_name,
        :login_link,
        entourage_title: action.title
      ]
    )
  end

  def event_created_confirmation event
    event_creator = event.user

    mailjet_email(
      to: event_creator,
      campaign_name: :event_created_confirmation,
      template_id: 491291,
      variables: [
        :first_name,
        :login_link,
        entourage_title: event.title
      ]
    )
  end

  #
  # Group joined
  #

  def event_joined_confirmation join_request
    event = join_request.joinable
    new_member = join_request.user

    mailjet_email(
      to: new_member,
      campaign_name: :event_joined_confirmation,
      template_id: 478397,
      variables: [
        :first_name,
        :login_link,
        entourage_title: event.title
      ]
    )
  end

  #
  # Event morning emails
  #

  def event_reminder_organizer join_request
    organizer = join_request.user
    event = join_request.joinable

    mailjet_email(
      to: organizer,
      campaign_name: :event_reminder_organizer,
      template_id: 513115,
      variables: [
        :first_name,
        event => [
          :entourage_url,
          :entourage_title
        ]
      ]
    )
  end

  def event_reminder_participant join_request
    participant = join_request.user
    event = join_request.joinable

    mailjet_email(
      to: participant,
      campaign_name: :event_reminder_participant,
      template_id: 491289,
      variables: [
        :first_name,
        :login_link,
        event => :entourage_title
      ]
    )
  end

  def event_followup_organizer join_request
    organizer = join_request.user
    event = join_request.joinable

    mailjet_email(
      to: organizer,
      campaign_name: :event_followup_organizer,
      template_id: 491294,
      variables: [
        :first_name,
        :login_link,
        event => :entourage_title
      ]
    )
  end
end
