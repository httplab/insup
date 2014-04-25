require 'uri'
require 'net/http'

class Insup::Uploader::HttpUploader < Insup::Uploader

  def upload_new_file file

  end


  def upload_modified_file file

  end


  def remove_file file

  end

  private

  def get_request action, file = nil
    action_config = get_action_config action

    context = {
      file_path = file.path
      file_state = file.state
    }

    if action_config.params
      params = apply_context_recursively(action_config['params'], context)
    end

    url_string = apply_context_recursively(action_config['url'], context)

    uri = URI.parse(url_string)

    case action_config['method']
    when 'get'
      request = Http::Get.new(uri.path)
    when 'post'
      request = Http::Post.new(uri.path)
    when 'put'
      request = Http::Put.new(uri.path)
    when 'delete'
      request = Http::Delete.new(uri.path)
    end
  end

  def get_action_config action
    action_config = @config.merge(@config[action])
    if action_config['method'].nil?
      action_config['method'] = 'post'
    end
  end

  def requires_login
    @config['login'].present?
  end

  def requires_logout
    @config['logout'].present?
  end

  def apply_context_recursively obj, context
    if obj.is_a? String
      obj % context
    elsif obj.is_a? Array
      obj.map |v| do
        apply_context_recursively(v, context)
      end
    elsif obj.is_a? Hash
      res = {}
      obj.each |k,v| do
        res[k] = apply_context_recursively(v, context)
      end

      res
    else
      obj
    end
  end

end
