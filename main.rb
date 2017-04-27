require 'rubygems'
gem 'google-api-client', '0.7'
require 'google/api_client'

class Main
  options = ARGV

  YOUTUBE_API_KEY = File.read('api_key')
  YOUTUBE_API_SERVICE_NAME = 'youtube'
  YOUTUBE_API_VERSION = 'v3'

  def self.get_service
    client = Google::APIClient.new(
        :key => YOUTUBE_API_KEY,
        :authorization => nil,
        :application_name => $PROGRAM_NAME,
        :application_version => '1.0.0'
    )
    youtube = client.discovered_api(YOUTUBE_API_SERVICE_NAME, YOUTUBE_API_VERSION)

    return client, youtube
  end


  def self.fetchList
    client = get_service
    search_response = client.execute!(
        :api_method => youtube.search.list,
        :parameters => {
            :part => 'snippet'
        }
    )

    videoList = []

    search_response.data.items.each do |search_result|
      case search_result.id.kind
        when 'youtube#video'
          videoList << "#{search_result.snippet.title}"
      end
    end

    puts "Videos:\n", videoList, "\n"

  end

  playlists = fetchList

  puts playlists
  puts options

end