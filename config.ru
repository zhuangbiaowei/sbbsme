if ENV['MY_RUBY_HOME'] && ENV['MY_RUBY_HOME'].include?('rvm')
  begin
    gems_path = ENV['MY_RUBY_HOME'].split(/@/)[0].sub(/rubies/,'gems')
    ENV['GEM_PATH'] = "#{gems_path}:#{gems_path}@global"
    require 'rvm'
    RVM.use_from_path! File.dirname(File.dirname(__FILE__))
  rescue LoadError
    raise "RVM gem is currently unavailable."
  end
end

# If you're not using Bundler at all, remove lines bellow
ENV['BUNDLE_GEMFILE'] = File.expand_path('./Gemfile', File.dirname(__FILE__))
ENV['RACK_ENV']="development"
require 'omniauth'
require 'omniauth-google-oauth2'
require 'bundler/setup'
require './main.rb'

OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
use Rack::Session::Cookie, :secret => ENV['RACK_COOKIE_SECRET']
use OmniAuth::Builder do
	provider :google_oauth2, '876356697116.apps.googleusercontent.com', 'Sc9hk9vgfb5nQCYCSG1niCoM', {}
end

run Sinatra::Application
