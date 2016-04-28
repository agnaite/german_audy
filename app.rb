require 'rubygems'
require 'oauth'
require 'json'
require 'sinatra'
require 'shotgun'

# Now you will fetch /1.1/statuses/user_timeline.json,
# returns a list of public Tweets from the specified
# account.
baseurl = "https://api.twitter.com"
path    = "/1.1/statuses/user_timeline.json"
query   = URI.encode_www_form(
    "screen_name" => "heyaudy",
    "count" => 10,
)
address = URI("#{baseurl}#{path}?#{query}")
request = Net::HTTP::Get.new address.request_uri

# Print data about a list of Tweets

# Set up HTTP.
http             = Net::HTTP.new address.host, address.port
http.use_ssl     = true
http.verify_mode = OpenSSL::SSL::VERIFY_PEER

# If you entered your credentials in the first
# exercise, no need to enter them again here. The
# ||= operator will only assign these values if
# they are not already set.
consumer_key = OAuth::Consumer.new(
    "FYf3OfDOowheyjvqskviob3T2",
    "7xLXzCc7FOMCkBDtqNG69WWvoCkVKCyJehd80P3bWAXGWmhDYz")
access_token = OAuth::Token.new(
    "8570212-hLy9t4sE5bVWEWKKqgGpauosnYWR2CpVIuf1PFIVMq",
    "SBY00PrBPeojb6bZufDBE1LQme1bpqJOH9nWyD7TFzcO0")

# Issue the request.
request.oauth! http, consumer_key, access_token
http.start
response = http.request request

# Parse and print the Tweet if the response code was 200
tweets = nil
if response.code == '200' then
  tweets = JSON.parse(response.body)
end

g_key = "AIzaSyDLet8h0bMWTWBdVPvs6_fT_-adUZQTAds"
source = "en"
target = "de"
translated_tweets = []

tweets.each do |tweet|
  final_tweet = ""
  final_tweet << URI.escape(tweet["text"])
  uri = URI("https://www.googleapis.com/language/translate/v2?key=#{g_key}&q=#{final_tweet}&source=#{source}&target=#{target}")
  g_response = Net::HTTP.get(uri)
  translate = JSON.parse(g_response)
  arr = translate["data"]["translations"]
  translated_tweets << arr[0]["translatedText"]
end

puts translated_tweets

get '/' do
  erb :index, :locals => {tweets: translated_tweets}
end
nil
