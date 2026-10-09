# frozen_string_literal: true

require_relative '../../../round/operating'
module Engine
  module Game
    module G1835
      module Round
        class Operating < Engine::Round::Operating
          def select_entities
            if @game.option_clemens? && !@game.corporation_by_id('BY').floated?
              @log << 'Bayern was not floated during the draft, minors will get skipped this OR'

              # since corps are floated in a strict order of which BY is the first, we can safely return [] here without
              # having to worry about accidentally skipping another corp
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
