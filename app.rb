require 'oauth'
require 'json'
require 'sinatra'
require 'shotgun'
require 'action_view'
require 'twitter'
require 'uri'

include ActionView::Helpers::DateHelper
 
client = Twitter::REST::Client.new do |config|
  config.consumer_key        = ENV['CONSUMER_KEY']
  config.consumer_secret     = ENV['CONSUMER_SECRET']
  config.access_token        = ENV['ACCESS_TOKEN']
  config.access_token_secret = ENV['ACCESS_SECRET']
end

def get_tweets(lang, client)
  tweets = client.user_timeline('heyaudy', count: 10)
  puts tweets

  g_key = "AIzaSyDLet8h0bMWTWBdVPvs6_fT_-adUZQTAds"
  source = "en"
  target = lang

  translated_tweets = []

  tweets.each do |tweet|
    tweet = tweet.full_text
    puts tweet.instance_of? String
    final_tweet = ""
    final_tweet << URI.escape(tweet)
    # uri = URI("https://www.googleapis.com/language/translate/v2?key=#{g_key}&q=#{final_tweet}&source=#{source}&target=#{target}")
    # g_response = Net::HTTP.get(uri)
    # translate = JSON.parse(g_response)
    # arr = translate["data"]["translations"]
    # translated_tweets[tweet["id_str"]] = [arr[0]["translatedText"]]
    # translated_tweets[tweet["id_str"]] << tweet["created_at"]
    translated_tweets << tweet
    puts translated_tweets
  end
  translated_tweets
end

get '/' do
  @lang = "de"
  @tweets = get_tweets(@lang, client)
  erb :index
end

post '/lang' do
  @lang = params[:lang]
  if @lang == "de"
    redirect '/'
  end
  @tweets = get_tweets(@lang, client)
  erb :index
end
