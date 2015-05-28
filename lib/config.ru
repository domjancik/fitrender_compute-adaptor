require 'rubygems'
require 'bundler'

Bundler.require

require ::File.join( ::File.dirname(__FILE__), 'fitrender_compute_adaptor' )
run FitrenderComputeAdaptor.new