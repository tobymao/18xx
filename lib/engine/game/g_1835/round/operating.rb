# frozen_string_literal: true

require_relative '../../../round/operating'
module Engine
  module Game
    module G1835
      module Round
        class Operating < Engine::Round::Operating
          def select_entities
            if @game.option_clemens? && !@game.corporation_by_id('BY').floated?
              @log << 'Bayern was not floated in draft, minors will get skipped this OR'
              return []
            end

            super
          end

          def setup
            @game.conversion_choice_during_or = false
            super
          end

          def pending_tokens
            @pending_tokens ||= []
          end
        end
      end
    end
  end
end
