# frozen_string_literal: true

require 'lib/request'

module Api
  def safe_post(path, params, &block)
    Lib::Request.post(path, params) do |data|
      if (error = data['error'])
        store(:flash_opts, error)
      elsif block
        block.call(data)
      end
    end
  end
end
