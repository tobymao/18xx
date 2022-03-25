# frozen_string_literal: true

require_relative '../../../ability/base'

module Engine
  module Game
    module GRollingStock
      module Ability
        class Stars < Engine::Ability::Base
          def description
            'Extra 2★ '
          end

          def desc_detail
            'Always adds 2 addtional ★s to its ★ count'
          end
        end
      end
    end
  end
end
