# encoding: utf-8

require 'fitrender/adaptor/condor'
require 'json'

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

  # Renderer update options
  patch '/renderers/:id' do
    begin
      renderer = adaptor.renderer(params[:id])
      puts params
      params.each do |key, value|
        puts key
        next if %w(splat captures id).include? key
        renderer.option_set_value key, value
      end
      json_success 'Renderer updated successfuly'
    rescue Fitrender::OptionNotFoundError => error
      json_error_bad_request "Some of the given options are not valid for the renderer. #{error.message}"
    rescue Fitrender::RendererNotFoundError
      json_error_not_found "Renderer #{params[:id]}"
    end
  end

  # Renderer overview
  get '/renderers/?' do
    json adaptor.renderers.inject([]) { |renderers, renderer| renderers << renderer.to_hash }
  end

  ### Jobs

  # Scene submission, returns a list of job_ids assigned to the scene
  post '/submit' do
    begin
      check_params(:path, :renderer_id, :options)
      options = JSON.parse(params[:options])

      scene = Fitrender::Adaptor::Scene.new(
        path: params['path'],
        renderer_id: params['renderer_id'],
        options: options,
      )

      json adaptor.submit(scene).inject([]) { |arr, job| arr << job.to_hash }
    rescue ArgumentError
      json_error_bad_request('Some of the required parameters (scene_path, renderer_id, options in JSON) are missing')
    rescue JSON::ParserError
      json_error_bad_request('The options given are not valid JSON')
    rescue Fitrender::RendererNotFoundError
      json_error_bad_request("Invalid renderer - #{params['renderer_id']}")
    rescue Fitrender::FileNotFoundError
      json_error_bad_request("File unreachable - #{params['path']}")
    end
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
  get '/options/?' do
    options = adaptor.options_list
    json options.inject([]) { |a, option| a << option.to_hash }
  end

  get '/options/:id' do
    option = adaptor.option_get params['id']
    json option.to_hash
  end

  patch '/options/:id' do
    return json_error_bad_request 'Missing value parameter' unless params.has_key? 'value'
    adaptor.option_set_value params['id'], params['value']
    json_success
  end

  private
  def json_error(status_code, message)
    status status_code
    json ({ 'error' => message })
  end

  def json_success(message = '')
    status 200
    json ({ 'success' => message })
  end

  def check_params(*required_params)
    required_params.each do |param|
      raise ArgumentError unless params.has_key? param.to_s
    end
  end

  def json_error_not_found(object_message)
    json_error 404, "404 Not Found: #{object_message}"
  end

  def json_error_bad_request(message)
    json_error 400, "400 Bad Request: #{message}"
  end

  def adaptor
    # TODO: Configurable adaptor
    Fitrender::Adaptor::CondorShellAdaptor.new
  end
end