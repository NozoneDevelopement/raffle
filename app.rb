# allow use of gems
require 'sinatra'
require 'sinatra/reloader'
require 'sequel'
require 'digest/sha1'

# require all other .rb files
Dir[File.dirname(__FILE__) + '/public/rb/*.rb'].each { |file| require file }

set :bind, '0.0.0.0'

enable :sessions
set :session_secret, 'B1la6vNypB8COMgTSwcaJ9IA2Ii4WRUU9i2on2ednMgHowMoxCIrfGLCgmI8'

# allows use of html escaping
helpers do
    include Rack::Utils
    alias_method :h, :escape_html
end