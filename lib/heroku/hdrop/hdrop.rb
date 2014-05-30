require 'uri'
require 'net/https'

module Heroku::HDrop

  class DropFile

    HDROP_ENDPOINT = "https://hdrop.herokuapp.com"

    attr_reader :get, :put

    def initialize
      urls = Heroku::Helpers.json_decode(Excon.new(HDROP_ENDPOINT).request({ :expects => 200, :method => :get}).body)
      @get = urls["get"]
      @put = urls["put"]
    end

    def upload(file)
      uri = URI.parse(@put)
      https = Net::HTTP.new(uri.host, uri.port)
      https.use_ssl = true
      request = Net::HTTP::Put.new(uri.request_uri, { 
        'Content-Length' => File.size(file).to_s, 
        'Accept' => '*/*', 
        'Content-Type' => '' 
      })
      request.body_stream=File.open(file)
      response=https.request(request)
      # puts "Request Headers: #{request.to_hash.inspect}"
      # puts "Sending PUT #{uri.request_uri} to #{uri.host}:#{uri.port}"
      # puts "Response #{response.code} #{response.message}"
      # puts "#{response.body}"
      # puts "Headers: #{response.to_hash.inspect}"
    end

  end

end