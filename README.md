# youtube-playlist-song-searcher
This application will fetch the songs in the playlist and allow you to find some of them without having to scroll on web

## Requirements

* Ruby
* RubyGems
* RubyBundler

## Installation

```
bundler install
```

## Get started
```
Add the urls of the playlist in the upload_lists, one line after each other.
Add the api_key in the file with the same name
```

## Get the playlist name and the index in front
```
ruby main.rb -l
```

## Display all the videos in that playlist
```
ruby main.rb -l \\ Will return something like 0 - Liked videos (remember the index)
ruby main.rb -p 0 -d \\ Will find all the videos in playlist one and display them
```

## Find a specific title
```
ruby main.rb -a -s 'Sinatra' \\ Will look into all the playlist for a title that includes Sinatra
```

## Help
```
ruby main.rb -h
```