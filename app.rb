require 'oauth'
require 'json'
require 'sinatra'
require 'shotgun'
require 'action_view'

include ActionView::Helpers::DateHelper

# Now you will fetch /1.1/statuses/user_timeline.json,
# returns a list of public Tweets from the specified
# account.

consumer_key = OAuth::Consumer.new(ENV['CONSUMER_KEY'], ENV['CONSUMER_SECRET'])
access_token = OAuth::Token.new(ENV['ACCESS_TOKEN'], ENV['ACCESS_SECRET'])

baseurl = "https://api.twitter.com"
path    = "/1.1/statuses/user_timeline.json"
query   = URI.encode_www_form(
    "screen_name" => "heyaudy",
    "count" => 10,
)

address = URI("#{baseurl}#{path}?#{query}")
request = Net::HTTP::Get.new address.request_uri

# Set up HTTP.
http             = Net::HTTP.new address.host, address.port
http.use_ssl     = true
http.verify_mode = OpenSSL::SSL::VERIFY_PEER

http.start

request.oauth! http, consumer_key, access_token

def get_tweets(request, http, lang)
  response = http.request(request)
  # Parse and print the Tweet if the response code was 200
  tweets = nil
  if response.code == '200' then
    tweets = JSON.parse(response.body)
  end

  g_key = "AIzaSyDLet8h0bMWTWBdVPvs6_fT_-adUZQTAds"
  source = "en"
  target = lang

  translated_tweets = {}

  tweets.each do |tweet|
    final_tweet = ""
    final_tweet << URI.escape(tweet["text"])
    uri = URI("https://www.googleapis.com/language/translate/v2?key=#{g_key}&q=#{final_tweet}&source=#{source}&target=#{target}")
    g_response = Net::HTTP.get(uri)
    translate = JSON.parse(g_response)
    arr = translate["data"]["translations"]
    translated_tweets[tweet["id_str"]] = [arr[0]["translatedText"]]
    translated_tweets[tweet["id_str"]] << tweet["created_at"]
    puts translated_tweets
  end
  translated_tweets
end

get '/' do
  @lang = "de"
  @tweets = get_tweets(request, http, @lang)
  erb :index
end

post '/lang' do
  @lang = params[:lang]
  if @lang == "de"
    redirect '/'
  end
  @tweets = get_tweets(request, http, @lang)
  erb :index
end
