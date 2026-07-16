class Toolbox::BraveSearch < Toolbox

  describe :brave_search, <<~S
    Search the web for the indicated query using Brave Search.
    Use this to answer questions about current events, look up information, or find answers to questions.
    Try to use this sparingly; prefer to use the user's memories and the tools you have available to answer questions.
    When you do use this, try to use exact queries for which you expect to get a definitive answer.
    When you respond to the user, try to include an answer to the question rather than just a link.
  S

  def brave_search(query_s:, count_i: 5)
    response = get("https://api.search.brave.com/res/v1/web/search").param(
      q: query_s,
      count: count_i
    )

    results = (response.try(:web)&.results || [])

    {
      message_to_user: "Web search: #{query_s}",
      results: results.map do |result|
        {
          title: result.try(:title),
          url: result.try(:url),
          description: result.try(:description),
          age: result.try(:age)
        }.compact
      end.take(count_i)
    }
  end

  private

  def header
    {
      "X-Subscription-Token" => Setting.brave_search_api_key,
      content_type: "application/json"
    }
  end

  def expected_status
    [200]
  end
end
