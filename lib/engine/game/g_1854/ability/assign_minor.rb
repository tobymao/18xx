# frozen_string_literal: true

require_relative '../../../ability/base'

module Engine
  module Game
    module G1854
      module Ability
        class AssignMinor < Engine::Ability::Base
          attr_reader :corp_sym

          def initialize(**opts)
            @corp_sym = opts[:corp_sym]
            super
          end
        end
      end
    end
  end
end
