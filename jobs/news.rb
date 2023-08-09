require 'faraday'

class News
  # ...

  def latest_headlines()
    news_headlines = []

    conn = Faraday.new(:url => @feed) do |faraday|
      faraday.adapter Faraday.default_adapter
    end

    response = conn.get

    feed = RSS::Parser.parse(response.body)
    feed.items.each do |item|
      title = clean_html(item.title.to_s)
      begin
        summary =  truncate(clean_html(item.description))
      rescue
        doc = Nokogiri::HTML(item.summary.content)
        summary = truncate((doc.xpath("//text()").remove).to_s)
      end
      news_headlines.push({ title: title, description: summary })
    end

    news_headlines
  end

  # ...
end
