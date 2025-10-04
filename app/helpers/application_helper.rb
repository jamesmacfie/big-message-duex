module ApplicationHelper
  def markdown(text)
    return "" if text.blank?

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

    markdown.render(text).html_safe
  end
end
