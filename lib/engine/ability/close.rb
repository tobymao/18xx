# frozen_string_literal: true

require_relative 'base'

module Engine
  module Ability
    class Close < Base
      attr_accessor :corporation, :silent

      def setup(corporation: nil, silent: false)
        @corporation = corporation
        @silent = silent
      end
    end
  end
end
