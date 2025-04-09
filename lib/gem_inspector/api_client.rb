require 'json'

begin
  require 'httparty'
  HTTPARTY_AVAILABLE = true
rescue LoadError
  require 'net/http'
  require 'uri'
  HTTPARTY_AVAILABLE = false
end

module GemInspector
  class ApiClient
    RUBYGEMS_API_URL = "https://rubygems.org/api/v1/versions"

    # Fetch gem version data from RubyGems.org API
    #
    # @param gem_name [String] Name of the gem
    # @return [Array<Hash>] Array of version data hashes
    def self.fetch_gem_data(gem_name)
      url = "#{RUBYGEMS_API_URL}/#{gem_name}.json"

      if HTTPARTY_AVAILABLE
        fetch_with_httparty(url)
      else
        fetch_with_net_http(url)
      end
    end

    private

    def self.fetch_with_httparty(url)
      begin
        response = HTTParty.get(url, timeout: 10)

        if response.code == 200
          JSON.parse(response.body)
        else
          raise Error, "API request failed with status #{response.code}: #{response.message}"
        end
      rescue HTTParty::Error, Timeout::Error => e
        raise Error, "Network error while fetching gem data: #{e.message}"
      rescue JSON::ParserError => e
        raise Error, "Invalid JSON response from RubyGems.org: #{e.message}"
      rescue => e
        raise Error, "Unexpected error: #{e.message}"
      end
    end

    def self.fetch_with_net_http(url)
      begin
        uri = URI.parse(url)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = (uri.scheme == 'https')
        http.open_timeout = 10
        http.read_timeout = 10

        request = Net::HTTP::Get.new(uri.request_uri)
        response = http.request(request)

        if response.code.to_i == 200
          JSON.parse(response.body)
        else
          raise Error, "API request failed with status #{response.code}: #{response.message}"
        end
      rescue Net::HTTPError, Timeout::Error => e
        raise Error, "Network error while fetching gem data: #{e.message}"
      rescue JSON::ParserError => e
        raise Error, "Invalid JSON response from RubyGems.org: #{e.message}"
      rescue => e
        raise Error, "Unexpected error: #{e.message}"
      end
    end
  end
end
