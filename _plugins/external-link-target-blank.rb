# frozen_string_literal: true

Jekyll::Hooks.register [:pages, :posts, :documents], :post_render do |doc|
  next unless doc.output_ext == '.html'

  site_url = doc.site.config['url'].to_s

  doc.output = doc.output.gsub(
    /<a\s+([^>]*href=["']https?:\/\/(?!#{Regexp.escape(site_url.sub(%r{^https?://}, ''))})([^"']+)["'][^>]*)>/i
  ) do |match|
    next match if match.include?('target=')

    match.sub('<a ', '<a target="_blank" rel="noopener noreferrer" ')
  end
end