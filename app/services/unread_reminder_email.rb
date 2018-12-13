module UnreadReminderEmail
  def self.join_requests_with_unread_items since: nil, community: :entourage
    entourages_scope = Entourage
    .findable
    .where(community: community)

    JoinRequest
    .accepted
    .joins(:entourage).merge(entourages_scope)
    .where(greater_than 'entourages.updated_at', 'last_message_read')
    .where(greater_than 'entourages.updated_at', 'email_notification_sent_at')
  end

  def self.unread_messages_for user
    ChatMessage
    .where(message_type: :text)
    .joins_group_join_requests.merge(user.join_requests.accepted)
    .where(greater_than 'chat_messages.created_at', 'last_message_read')
  end

  def self.pending_join_requests_for user
    JoinRequest
    .where(status: :pending)
    .joins(:entourage).merge(user.entourages.findable)
    .where(greater_than 'join_requests.requested_at', 'last_message_read')
  end

  def self.deliver_to user
    now = Time.now
    presenter = Presenter.new(user)

    return unless presenter.deliver?

    MemberMailer.mailjet_email(
      to: user,
      template_id: 604694,
      campaign_name: :unread_reminder,
      variables: {
        subject: presenter.subject,
        nb_1: presenter.nb_1,
        nb_1_text: presenter.nb_1_text,
        nb_2: presenter.nb_2,
        nb_2_text: presenter.nb_2_text,
        items_summary: presenter.items_summary,
        author_summary: presenter.author_summary,
        groups: presenter.groups
      }
    ).deliver_now

    JoinRequest
      .where(user: user, joinable_id: presenter.group_ids, joinable_type: :Entourage)
      .update_all(email_notification_sent_at: now)
  end

  def self.summary user
    Summary.new(user)
  end

  class Summary
    attr_reader :total_unread_messages,
                :total_pending_join_requests,
                :authors,
                :groups

    def initialize user
      unread_messages = UnreadReminderEmail.unread_messages_for(user)
      pending_join_requests = UnreadReminderEmail.pending_join_requests_for(user)

      @total_unread_messages = unread_messages.count
      @total_pending_join_requests = pending_join_requests.count

      new_unread_messages =
        unread_messages
        .where(greater_than 'chat_messages.created_at', 'email_notification_sent_at')

      new_unread_messages_per_group =
        new_unread_messages.group(:messageable_id).count

      new_pending_join_requests =
        pending_join_requests
        .where(greater_than 'join_requests.requested_at', 'email_notification_sent_at')

      new_pending_join_requests_per_group =
        new_pending_join_requests.group(:joinable_id).count

      @authors = Hash.new(0)

      new_unread_messages.group(:user_id).count.each do |user_id, count|
        @authors[user_id] += count
      end

      new_pending_join_requests.group(:user_id).count.each do |user_id, count|
        @authors[user_id] += count
      end

      group_ids = (
        new_unread_messages_per_group.keys +
        new_pending_join_requests_per_group.keys
      ).uniq

      @groups = {}
      group_ids.each do |group_id|
        @groups[group_id] = {
          messages: (new_unread_messages_per_group[group_id] || 0),
          requests: (new_pending_join_requests_per_group[group_id] || 0)
        }
      end
    end

    private
    def greater_than(*args); UnreadReminderEmail.greater_than(*args); end
  end

  class Presenter
    attr_reader :summary

    def initialize user
      @user = user
      @summary = UnreadReminderEmail.summary(user)
      @many_items = summary.authors.map(&:last).sum > 1
      author_ids = summary.authors.sort_by(&:last).reverse.map(&:first)
      @many_authors = author_ids.count > 1

      if author_ids.count > 0
        @first_author = UserService.name(
          User.select(:first_name, :last_name).find(author_ids.first))
      end
    end

    def deliver?
      summary.groups.any?
    end

    def subject
      [
        @first_author,
        ("et d'autres membres du réseau" if @many_authors),
        (@many_authors ? "vous ont envoyé" : "vous a envoyé"),
        (@many_items ? "des messages" : "un message")
      ].compact.join(' ')
    end

    def nb_1
      summary.total_unread_messages
    end

    def nb_1_text
      if summary.total_unread_messages == 1
        "message non lu"
      else
        "messages non lus"
      end
    end

    def nb_2
      summary.total_pending_join_requests
    end

    def nb_2_text
      if summary.total_pending_join_requests == 1
        "demande en attente"
      else
        "demandes en attente"
      end
    end

    def items_summary
      if @many_items
        "de nouveaux messages"
      else
        "un nouveau message"
      end
    end

    def author_summary
      [
        @first_author,
        ("et d'autres membres" if @many_authors)
      ].compact.join(' ')
    end

    def group_summary group
      unreads = summary.groups[group.id]

      messages_summary =
        case unreads[:messages]
        when 0
          nil
        when 1
          "1 nouveau message"
        else
          "#{unreads[:messages]} nouveaux messages"
        end

      requests_summary =
        case unreads[:requests]
        when 0
          nil
        when 1
          "1 demande en attente"
        else
          "#{unreads[:requests]} demandes en attente"
        end

      text = [messages_summary, requests_summary].compact.join(" et ")
      text += " dans votre conversation privée" if group[:type] == 'conversation'

      text
    end

    def groups
      groups =
        Entourage.where(id: summary.groups.keys)
        .order(%(
          case
          when user_id = #{Integer(@user.id)} then
            1
          when group_type = 'conversation' then
            2
          else
            3
          end,
          updated_at desc
        ))

      auth_token = UserServices::UserAuthenticator.auth_token(@user)
      groups.map do |group|
        image_url = nil
        title = group.title

        case group.group_type
        when 'action'
          type = group.entourage_type
        when 'outing'
          type = 'event'
        when 'conversation'
          other = group.members.where.not(id: @user.id).first
          image_url = UserServices::Avatar.new(user: other).thumbnail_url(expire: 7.days)
          type = image_url ? 'conversation_with_image_url' : 'conversation'
          title = UserService.name(other)
        end

        {
          title: title,
          type: type,
          image_url: image_url,
          summary: group_summary(group),
          url: "#{ENV['WEBSITE_URL']}/entourages/#{group.uuid_v2}?auth=#{auth_token}"
        }
      end
    end

    def group_ids
      summary.groups.keys
    end
  end

  private
  def self.greater_than left, right
    "#{left} > #{right} or #{right} is null"
  end
end
