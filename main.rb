require 'rubygems'
require 'google/api_client'
require 'optparse'

YOUTUBE_API_KEY = File.read('api_key')
YOUTUBE_API_SERVICE_NAME = 'youtube'
YOUTUBE_API_VERSION = 'v3'
UPLOAD_LIST_IDS = []

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


def populatePlaylist
  File.readlines('upload_lists').each do |line|
    UPLOAD_LIST_IDS.push(line)
  end
end

def displayPlaylists
  i=0
  client, youtube = get_service
  UPLOAD_LIST_IDS.each{|id|
    playlistitems_response = client.execute!(
        :api_method => youtube.playlists.list,
        :parameters => {
            :id => id,
            :part => 'snippet',
        }
    )

    playlistitems_response.data.items.each do |playlist_item|
      puts String(i) << ' - '  << playlist_item['snippet']['title']
      i+=1
    end
  }
end

def list_fetcher(index)
  client, youtube = get_service

  begin
    uploads_list_id = UPLOAD_LIST_IDS[index]
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

      playlistitems_response.data.items.each do |playlist_item|
        title = playlist_item['snippet']['title']
        videos.push("#{title}")
      end

      next_page_token = playlistitems_response.next_page_token
    end
    return videos
  end
rescue Google::APIClient::TransmissionError => e
  puts e.result.body

end

optparse = OptionParser.new do |opts|
  videos = []
  populatePlaylist

  opts.on( '-s', '--search NAME', 'Find by string' ) do |name|
    result = []
    (Array (videos)).each do |elem|
        if elem.include? name
         result.push(elem)
        end
    end
    puts result
  end

  opts.on( '-a', '--all', 'Fetches from all playlists' ) do
    UPLOAD_LIST_IDS.length.times{|index| videos.push(list_fetcher(index))}
  end

  opts.on( '-p', '--playlist INDEX', 'Fetches from a specific playlist' ) do |index|
    videos = list_fetcher(Integer(index))
  end

  opts.on( '-l', '--listplaylists', 'Displays all playlists') do
    displayPlaylists
  end

  opts.on( '-d', '--display' , 'Displays all the songs in the playlists selected' )do
    puts videos;
  end

  opts.on( '-h', '--help', 'Display this screen' ) do
    puts opts
    exit
  end
end
optparse.parse!
