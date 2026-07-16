require "test_helper"

class Toolbox::BraveSearchTest < ActiveSupport::TestCase
  setup do
    @brave_search = Toolbox::BraveSearch.new
    WebMock.enable! # defend against WebMock state leaked by other toolbox tests (e.g. open_meteo_test calls WebMock.disable!)
  end

  test "brave_search parses and returns results" do
    stub_settings(brave_search_api_key: "test-key") do
      stub_request(:get, "https://api.search.brave.com/res/v1/web/search?count=5&q=ruby%20on%20rails")
        .to_return(status: 200, body: {
          type: "search",
          query: { original: "ruby on rails" },
          web: {
            results: [
              { title: "Ruby on Rails", url: "https://rubyonrails.org", description: "A web-application framework.", age: "1 week ago" },
              { title: "Getting Started with Rails", url: "https://guides.rubyonrails.org", description: "Getting Started with Rails", age: "2 weeks ago" }
            ]
          }
        }.to_json, headers: { "Content-Type" => "application/json" })

      result = @brave_search.brave_search(query_s: "ruby on rails", count_i: 5)

      assert_equal "Web search: ruby on rails", result[:message_to_user]
      assert_equal 2, result[:results].length
      assert_equal "Ruby on Rails", result[:results].first[:title]
      assert_equal "https://rubyonrails.org", result[:results].first[:url]
      assert_equal "A web-application framework.", result[:results].first[:description]
      assert_equal "1 week ago", result[:results].first[:age]
    end
  end

  test "brave_search handles missing web results gracefully" do
    stub_settings(brave_search_api_key: "test-key") do
      stub_request(:get, "https://api.search.brave.com/res/v1/web/search?count=5&q=no%20results%20query")
        .to_return(status: 200, body: {
          type: "search",
          query: { original: "no results query" },
          web: nil
        }.to_json, headers: { "Content-Type" => "application/json" })

      result = @brave_search.brave_search(query_s: "no results query", count_i: 5)

      assert_equal "Web search: no results query", result[:message_to_user]
      assert_empty result[:results]
    end
  end

  test "brave_search works as a tool call" do
    stub_settings(brave_search_api_key: "test-key") do
      stub_request(:get, "https://api.search.brave.com/res/v1/web/search?count=5&q=ruby")
        .to_return(status: 200, body: {
          type: "search",
          query: { original: "ruby" },
          web: {
            results: [
              { title: "Ruby", url: "https://www.ruby-lang.org", description: "A dynamic, open source programming language." }
            ]
          }
        }.to_json, headers: { "Content-Type" => "application/json" })

      result = Toolbox.call("bravesearch_brave_search", query: "ruby", count: 5)

      assert_equal "Web search: ruby", result[:message_to_user]
      assert_equal 1, result[:results].length
      assert_equal "Ruby", result[:results].first[:title]
    end
  end

  test "descendants includes BraveSearch when key is present" do
    stub_settings(brave_search_api_key: "test-key") do
      assert_includes Toolbox.descendants, Toolbox::BraveSearch
    end
  end

  test "descendants excludes BraveSearch when key is blank" do
    stub_settings(brave_search_api_key: nil) do
      assert_not_includes Toolbox.descendants, Toolbox::BraveSearch
    end
  end
end
