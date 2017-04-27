require 'rubygems'
gem 'google-api-client', '0.7'
require 'google/api_client'

options = ARGV

YOUTUBE_API_KEY = File.read('api_key')
YOUTUBE_API_SERVICE_NAME = 'youtube'
YOUTUBE_API_VERSION = 'v3'

def get_service
  client = Google::APIClient.new(
      :key => YOUTUBE_API_KEY,
      :authorization => nil,
      :application_name => $PROGRAM_NAME,
      :application_version => '1.0.0'
  )
  youtube = client.discovered_api(YOUTUBE_API_SERVICE_NAME, YOUTUBE_API_VERSION)


  return client, youtube
end


def main
  client, youtube = get_service

  begin
    uploads_list_id = File.read('upload_lists')

    playlistitems_response = client.execute!(
        :api_method => youtube.playlist_items.list,
        :parameters => {
            :playlistId => uploads_list_id,
            :part => 'snippet',
        }
    )

    next_page_token = ''
    videos = []
    until next_page_token.nil?
      playlistitems_response = client.execute!(
          :api_method => youtube.playlist_items.list,
          :parameters => {
              :playlistId => uploads_list_id,
              :part => 'snippet',
              :maxResults => 50,
              :pageToken => next_page_token
          }
      )


      # Print information about each video.

      playlistitems_response.data.items.each do |playlist_item|
        title = playlist_item['snippet']['title']
        videos.push("#{title}")
      end


      next_page_token = playlistitems_response.next_page_token
    end
    puts "Videos:\n", videos, "\n"
  end
rescue Google::APIClient::TransmissionError => e
  puts e.result.body

  return videos
end

main