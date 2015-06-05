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
      json_error_not_found "Node #{params[:id]}"
    end
  end

  # Job state
  get '/job/:id' do
    begin
      json adaptor.job(params[:id])
    rescue Fitrender::NotFoundError
      json_error_not_found "Job #{params[:id]}"
    end
  end

  private
  def json_error(status_code, message)
    status status_code
    json ({ 'error' => message })
  end

  def json_error_not_found(object_message)
    json_error 404, "404 Not Found: #{object_message}"
  end

  def adaptor
    # TODO: Configurable adaptor
    Fitrender::Adaptor::CondorShellAdaptor.new
  end
end