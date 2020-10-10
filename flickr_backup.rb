#!/usr/bin/env ruby

require 'flickraw'
require 'open-uri'

class FlickrBackup
  # You can customize these
  BACKUP_DIRECTORY = "backup"
  SECONDS_BETWEEN_DOWNLOADS = 0 # Increase if you want to throttle
  MAX_TITLE_LENGTH_IN_FILENAME = 150 # Avoids Errno::ENAMETOOLONG
  CREDENTIALS_FILENAME = "authentication_data"
  FLICKR_USERNAME_FILENAME = "username"

  # These seem safe to share (since a malicious party would need the downloaded
  # credentials to do anything), but let me know otherwise!
  FLICKR_BACKUP_API_KEY = "6a805bb1fd62642608d2ad8e7a4ec555"
  FLICKR_BACKUP_SHARED_SECRET = "f164387e68651041"

  class << self
    # Change this to customize how album directories are named
    def album_directory(album)
      "#{BACKUP_DIRECTORY}/#{strip_odd_chars(album.title)}".unicode_normalize
    end

    # Change this to customize how photo files are named
    # Keep in mind that:
    #  - They must be inside album_directory(album)
    #  - They must be unique (so using photo.id as part of the name is a good idea)
    def photo_file(photo, album)
      title = photo.title[0..MAX_TITLE_LENGTH_IN_FILENAME - 1]
      "#{album_directory(album)}/#{strip_odd_chars(title)}_#{photo.id}.#{photo.originalformat}".unicode_normalize
    end

    # Main loop: creates a directory for each album on a Flickr account,
    # downloading the photos on that album just like they were uploaded
    # (original size, EXIF tags, etc)
    def perform
      request_flickr_username
      authenticate_user
      create_backup_directory
      albums = flickr_albums
      save_metadata(albums)
      albums.each do |album|
        photos = flickr_photos(album)
        create_directory(album)
        download_missing(photos, album)
        delete_extraneous(photos, album)
      end
    end

    ## Core actions

    def download_missing(photos, album)
      photos.each do |photo|
        if downloaded?(photo, album)
          puts "Skipping #{photo_file(photo, album)}"
        else
          puts "Downloading #{photo_file(photo, album)}"
          download(photo, album)
          sleep SECONDS_BETWEEN_DOWNLOADS
        end
      end
    end

    def delete_extraneous(photos, album)
      existing = Dir.glob("#{album_directory(album)}/*").map(&:unicode_normalize)
      expected = photos.map { |photo| photo_file(photo, album) }
      extraneous = existing - expected

      extraneous.each do |filename|
        puts "Deleting #{File.basename(filename)}"
        File.delete(filename)
      end
    end

    def download(photo, album)
      filename = photo_file(photo, album)
      downloaded_data = URI.parse(source_url(photo)).read
      File.open(filename, "wb") do |file|
        file.write(downloaded_data)
      end
    rescue => e
      # If anything fails, don't keep the file
      # (so we'll try again for sure)
      File.delete(filename) if File.exists?(filename)
      raise
    end

    def downloaded?(photo, album)
      File.exists?(photo_file(photo, album))
    end

    ## Flickr authentication and credentials management

    def flickr
      @flickr ||= FlickRaw::Flickr.new(api_key: FLICKR_BACKUP_API_KEY, shared_secret: FLICKR_BACKUP_SHARED_SECRET)
    end

    def request_flickr_username
      # If we can load the stored username, we are good...
      return if load_flickr_username

      # ...otherwise, let's ask and store for the next time
      puts "Enter your flickr username (needed for mp4 downloads):"
      @flickr_username = gets
      save_flickr_username
    end

    def save_flickr_username
      File.open(FLICKR_USERNAME_FILENAME, 'w') { |f| f.write(@flickr_username) }
    end

    def load_flickr_username
      File.open(FLICKR_USERNAME_FILENAME, 'r') do |f|
        @flickr_username = f.readline.chomp
        return true
      end
    rescue => e
      false
    end

    def authenticate_user
      # If we can load stored credentials, we are good...
      return if load_credentials

      # ...otherwise, let's request permission on the browser...
      token = flickr.get_request_token
      auth_url = flickr.get_authorize_url(token['oauth_token'], :perms => 'read')

      puts "Open this url in your browser to complete the authentication process : #{auth_url}"
      puts "Copy here the number given when you complete the process."
      verify = gets.strip

      begin
        ### ...and if we can verify it succeeded, store the credentials for next time
        flickr.get_access_token(token['oauth_token'], token['oauth_token_secret'], verify)
        save_credentials
        puts "You are now authenticated. Your credentials are saved to the #{CREDENTIALS_FILENAME} file."
      rescue FlickRaw::FailedResponse => e
        abort "Authentication failed : #{e.msg}"
      end
    end

    def save_credentials
      File.open(CREDENTIALS_FILENAME, 'w') { |f| f.write([flickr.access_token, flickr.access_secret].join(",")) }
    end

    def load_credentials
      File.open(CREDENTIALS_FILENAME, 'r') do |f|
        flickr.access_token, flickr.access_secret = f.readline.split(",")
        return true
      end
    rescue => e
      false
    end

    ## Flickr elements (albums, photos and URLs)

    def flickr_albums
      flickr.photosets.getList
    end

    def flickr_photos(album)
      result = []
      page_number = 1
      loop do
        photoset = flickr.photosets.getPhotos(photoset_id: album.id, extras: "original_format", page: page_number)
        result += photoset.photo
        page_number += 1
        break if photoset.page == photoset.pages.to_s
      end
      result
    end

    def source_url(photo)
      if photo.originalformat == "mp4"
        "https://www.flickr.com/photos/#{@flickr_username}/#{photo.id}/play/orig/#{photo.originalsecret}"
      else
        "https://farm#{photo.farm}.staticflickr.com/#{photo.server}/#{photo.id}_#{photo.originalsecret}_o.#{photo.originalformat}"
      end
    end

    ## File and directory management

    def create_backup_directory
      Dir.mkdir(BACKUP_DIRECTORY) unless Dir.exists?(BACKUP_DIRECTORY)
    end

    def create_directory(album)
      Dir.mkdir(album_directory(album)) unless Dir.exists?(album_directory(album))
    end

    def save_metadata(album)
      File.write("#{BACKUP_DIRECTORY}/album_metadata", album.inspect)
    end

    def strip_odd_chars(filename)
      filename.tr('/','-').tr('\\','-')
    end
  end
end

if __FILE__==$0
  FlickrBackup.perform
end
