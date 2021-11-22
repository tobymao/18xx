# frozen_string_literal: true

require_relative 'operating'

module Engine
  module Game
    module G18NY
      module Round
        class Capitalization < Operating
          def name
            'Capitalization Round'
          end

          def self.short_name
            'CR'
          end

          def setup
            @current_operator = nil
            after_setup
          end

          def start_operating
            entity = @entities[@entity_index]
            @current_operator = entity
            @current_operator_acted = false
            skip_steps
            next_entity! if finished?
          end
        end
      end
    end
  end
end
