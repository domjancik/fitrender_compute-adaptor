# encoding: utf-8

require 'fitrender/adaptor/condor'

class FitrenderComputeAdaptor < Sinatra::Application
  ### Nodes

  # Node detail
  get '/nodes/:id' do
    begin
      json adaptor.node(params[:id]).to_hash
    rescue Fitrender::NotFoundError
      json_error_not_found "Node #{params[:id]}"
    end
  end

  # Node overview
  get '/nodes/?' do
    json adaptor.nodes.inject([]) { |nodes, node| nodes << node.to_hash }
  end

  ### Renderers

  # Renderer detail
  get '/renderers/:id' do
    begin
      json adaptor.renderer(params[:id]).to_hash
    rescue Fitrender::NotFoundError
      json_error_not_found "Renderer #{params[:id]}"
    end
  end

  # Renderer overview
  get '/renderers/?' do
    json adaptor.renderers.inject([]) { |renderers, renderer| renderers << renderer.to_hash }
  end

  # Job state
  get '/jobs/:id' do
    begin
      json adaptor.job(params[:id])
    rescue Fitrender::NotFoundError
      json_error_not_found "Job #{params[:id]}"
    end
  end

  # Adaptor Config
  get '/config/?' do
    options = @adaptor.config_list
    json options.inject([]) { |a, option| a << option.to_hash }
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