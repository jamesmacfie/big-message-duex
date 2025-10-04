module ApplicationHelper
  def markdown(text)
    return "" if text.blank?

    # First, process mentions to add highlighting before markdown rendering
    text_with_mentions = process_mentions(text)

    options = {
      filter_html: false,
      hard_wrap: true,
      link_attributes: { target: "_blank", rel: "noopener noreferrer" },
      space_after_headers: true,
      fenced_code_blocks: true,
      safe_links_only: true
    }

    extensions = {
      autolink: true,
      superscript: true,
      disable_indented_code_blocks: false,
      fenced_code_blocks: true,
      strikethrough: true,
      tables: true
    }

    renderer = Redcarpet::Render::HTML.new(options)
    markdown = Redcarpet::Markdown.new(renderer, extensions)

    markdown.render(text_with_mentions).html_safe
  end

  private

  def process_mentions(text)
    # Pattern to match @mentions: @Name or @FirstName LastName
    mention_pattern = /@([\w\s]+?)(?=\s|$|[^\w\s])/

    # Replace mentions with styled spans
    text.gsub(mention_pattern) do |match|
      name = $1
      # Wrap mention in a span with CSS classes for styling
      "<span class=\"mention\">@#{name}</span>"
    end
  end
end
