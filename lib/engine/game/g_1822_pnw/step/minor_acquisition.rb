# frozen_string_literal: true

require_relative '../../g_1822/step/minor_acquisition'

module Engine
  module Game
    module G1822PNW
      module Step
        class MinorAcquisition < Engine::Game::G1822::Step::MinorAcquisition
          include Engine::Game::G1822PNW::Connections

          def potentially_mergeable(entity)
            super.reject { |c| @game.associated_minor?(c) } + @game.regionals.select { |r| @game.regional_payout_count(r) > 1 }
          end

          def extra_transfers(minor, entity)
            minor.tokens.each do |token|
              next unless token == @game.coal_token

              token.corporation = entity
              entity.tokens << token
              minor.tokens.delete(token)
              return 'Mine token'
            end
            nil
          end
        end
      end
    end
  end
end
