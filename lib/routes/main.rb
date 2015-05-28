# encoding: utf-8
class FitrenderComputeAdaptor < Sinatra::Application
	get "/" do
		@title = "Welcome to MyApp"				
		haml :main
	end
end