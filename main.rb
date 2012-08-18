require 'rubygems'
require 'sinatra'
require 'mongoid'
require 'haml'
require './config/config'
require './config/oauth_config'
require './models/models'
require './controllers/controller_for_views'
require './controllers/controller_for_services'
require './controllers/controller_for_redirect'
require './lib/utils'

enable :sessions