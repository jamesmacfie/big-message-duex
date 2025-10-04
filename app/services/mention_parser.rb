class MentionParser
  # Pattern to match @mentions: @Name or @FirstName LastName
  MENTION_PATTERN = /@([\w\s]+?)(?=\s|$|[^\w\s])/

  def initialize(message)
    @message = message
  end

  def process
    # Clear existing mentions when processing (for updates)
    @message.mentions.destroy_all if @message.persisted?

    # Extract mentioned names from the content
    mentioned_names = extract_mentions(@message.content)
    return if mentioned_names.empty?

    # Find people in the channel who match these names
    channel_people = @message.channel.members.includes(:person).map(&:person)
    mentioned_people = find_matching_people(mentioned_names, channel_people)

    # Create mention records
    create_mentions(mentioned_people)
  end

  private

  def extract_mentions(content)
    return [] if content.blank?

    # Find all @mentions and extract the names
    content.scan(MENTION_PATTERN).flatten.map(&:strip).uniq
  end

  def find_matching_people(mentioned_names, channel_people)
    mentioned_people = []

    mentioned_names.each do |name|
      # Try to find a person with matching name
      person = channel_people.find do |p|
        p.name.casecmp(name).zero?
      end

      mentioned_people << person if person
    end

    mentioned_people.uniq
  end

  def create_mentions(people)
    people.each do |person|
      # Don't create a mention if the person is the message author
      next if person.id == @message.person_id

      # Create the mention (will be skipped if it already exists due to validation)
      @message.mentions.create(person: person)
    end
  end
end
