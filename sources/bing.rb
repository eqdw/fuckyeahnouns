require 'json'
require 'curb'
require 'base64'
require 'cgi'
require './sources/image_iterator'
require './sources/spice'


class Bing
  attr_reader :noun, :images, :result, :json
  include ImageIterator

  def initialize(noun)
    @noun = noun

    @images = []
    @result = nil
    @json   = nil
  end

  def self.fetch(noun)
    instance = new(noun)
    instance.search!
    instance
  end

  def search!
    @result = Bing.query(@noun)
    @json   = Bing.process_json(@result)

    @images = @json[:images]

    nil
  end

  def self.process_json(json)
    data = json.fetch("d")
    results = data.fetch("results")

    {
      total:  results.count,
      images: results.map { |image| image['MediaUrl'] }
    }
  end

  def self.query(noun)
    authKey = Base64.strict_encode64("#{key}:#{key}")
    options = {
      :$format => "json",
      :Query => "'#{noun}'"
    }

    result = Curl.get("https://api.datamarket.azure.com/Bing/Search/Image", options) do |http|
      http.headers['Authorization'] = "Basic #{authKey}"
    end

    JSON.parse(result.body_str)
  end

  def self.key
    ENV['BING_KEY']
  end
end

fail 'BING_KEY is missing' unless Bing.key
