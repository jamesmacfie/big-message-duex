class SearchService
  MAX_RESULTS_PER_TYPE = 10

  def initialize(query, current_person)
    @query = query.to_s.strip
    @current_person = current_person
  end

  def search
    return empty_results if @query.blank?

    {
      channels: search_channels,
      dms: search_dms,
      messages: search_messages
    }
  end

  private

  def search_channels
    # Search channels the user is a member of
    # Search by name and description
    @current_person.channels
      .active
      .where("channels.channel_type = ? AND (channels.name ILIKE ? OR channels.description ILIKE ?)",
             "channel", "%#{sanitize_query}%", "%#{sanitize_query}%")
      .order("CASE WHEN channels.name ILIKE ? THEN 1 ELSE 2 END, channels.name",
             "#{sanitize_query}%") # Prioritize starts with match
      .limit(MAX_RESULTS_PER_TYPE)
      .map do |channel|
        {
          id: channel.id,
          name: channel.name,
          description: channel.description,
          is_private: channel.is_private,
          type: "channel",
          member_count: channel.members.count
        }
      end
  end

  def search_dms
    # Search DMs the user is a member of
    # Search by participant names
    @current_person.channels
      .where(channel_type: "dm")
      .includes(:people)
      .select do |dm|
        # Get participant names (excluding current person)
        participants = dm.people.where.not(id: @current_person.id)
        participants.any? { |p| p.name.downcase.include?(@query.downcase) }
      end
      .first(MAX_RESULTS_PER_TYPE)
      .map do |dm|
        participants = dm.people.where.not(id: @current_person.id)
        {
          id: dm.id,
          name: participants.map(&:name).join(", "),
          type: "dm",
          participant_ids: participants.pluck(:id),
          participant_names: participants.map(&:name)
        }
      end
  end

  def search_messages
    # Search messages in channels the user has access to
    # Use PostgreSQL's ILIKE for case-insensitive search
    accessible_channel_ids = @current_person.channels.active.pluck(:id)

    Message
      .where(channel_id: accessible_channel_ids)
      .where(deleted_at: nil)
      .where("content ILIKE ?", "%#{sanitize_query}%")
      .includes(:person, :channel)
      .order(created_at: :desc)
      .limit(MAX_RESULTS_PER_TYPE)
      .map do |message|
        {
          id: message.id,
          content: truncate_content(message.content),
          highlighted_content: highlight_match(message.content),
          person_name: message.person.name,
          person_id: message.person.id,
          channel_id: message.channel.id,
          channel_name: message.channel.name,
          created_at: message.created_at,
          type: "message"
        }
      end
  end

  def sanitize_query
    # Escape special characters for ILIKE to prevent SQL injection
    @query.gsub(/[%_\\]/) { |char| "\\#{char}" }
  end

  def truncate_content(content, length: 150)
    return content if content.length <= length
    "#{content[0...length]}..."
  end

  def highlight_match(content)
    # Highlight the matching portion of the content
    # Replace matched text with a marker for frontend highlighting
    content.gsub(/#{Regexp.escape(@query)}/i) do |match|
      "<mark>#{match}</mark>"
    end
  end

  def empty_results
    {
      channels: [],
      dms: [],
      messages: []
    }
  end
end
