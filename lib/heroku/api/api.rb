require 'uri'
require 'net/https'

module Heroku

  class API

    def start_setup(url)
      data = { "source_blob" => { "url" => url }}
      return request(
        :method => :post,
        :expects => 202,
        :path => '/app-setups',
        :body => Heroku::OkJson.encode(data),
        :headers => {'Accept' => "application/vnd.heroku+json; version=#{api_version}"}
        ).body
    end

    def setup_result(id)
      return request(
        :method => :get,
        :expects => 200,
        :path => "/app-setups/#{id}",
        :headers => {'Accept' => "application/vnd.heroku+json; version=#{api_version}"}
        ).body
    end

    def start_build(url, app, version)
      data = { "source_blob" => { "url" => url, "version" => version }}
      response = request(
        :method => :post,
        :expects => [201, 503],
        :path => "/apps/#{app}/builds",
        :body => Heroku::OkJson.encode(data),
        :headers => {'Accept' => "application/vnd.heroku+json; version=#{api_version}"}
        )
      # this is a little messy. But the beginnings of supporting MFA per request
      if response.status == 503
        puts
        mfa = Heroku::Auth.ask_for_second_factor
        return request(
          :method => :post,
          :expects => 201,
          :path => "/apps/#{app}/builds",
          :body => Heroku::OkJson.encode(data),
          :headers => {'Accept' => "application/vnd.heroku+json; version=#{api_version}",
                       'Heroku-Two-Factor-Code' => mfa }
          ).body
      else
        return response.body
      end
    end

    def build_result(app, id)
      return request(
        :method => :get,
        :expects => 200,
        :path => "/apps/#{app}/builds/#{id}/result",
        :headers => {'Accept' => "application/vnd.heroku+json; version=#{api_version}"}
        ).body
    end

    private

      def api_version
        if ENV["STREAMING_BUILD_RESULT"]
          "edge"
        else
          "3"
        end
      end

  end
end