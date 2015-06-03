# encoding: utf-8

require 'fitrender/adaptor/condor'

class FitrenderComputeAdaptor < Sinatra::Application
	get '/nodes' do
    nodes = []
    adaptor.nodes.each { |node| nodes << node.to_hash }
    json nodes
  end

  get '/node/:id' do
    begin
      json adaptor.node(params[:id]).to_hash
    rescue Fitrender::NotFoundError
      json_error 404, "Node #{params[:id]} not found"
    end
  end

  private
  def json_error(status_code, message)
    status status_code
    json ({ 'error' => message })
  end

  def adaptor
    # TODO: Configurable adaptor
    Fitrender::Adaptor::CondorShellAdaptor.new
  end
end