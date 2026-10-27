# frozen_string_literal: true

require_relative '../../../step/track_and_token'
require_relative 'receivership_skip'

module Engine
  module Game
    module G1833NE
      module Step
        class TrackAndToken < Engine::Step::TrackAndToken
          include ReceivershipSkip

          def process_lay_tile(action)
            lay_tile_action(action)

            if action.entity == @game.lowell_merchants_company&.owner && @game.lowell_merchants_company_activated
              @game.remove_lowell_merchants_ability!
            end

            lay_joint_tokens! if action.hex.id == @game.class::SHERBROOKE_HEX && action.tile.color == :yellow

            pass! if !can_lay_tile?(action.entity) && @tokened
          end

          def lay_joint_tokens!
            hex = @game.hex_by_id(@game.class::SHERBROOKE_HEX)
            city = hex.tile.cities.first

            %w[StL&A A&StL].each do |corp_id|
              corp = @game.corporation_by_id(corp_id)
              next unless corp

              token = Engine::Token.new(corp, price: 0)
              city.place_token(corp, token, free: true, check_tokenable: false)
              corp.tokens << token
              @log << "#{corp.name} receives a free special token in #{hex.name} (rule 6.53)"
            end

            @game.graph.clear
          end
        end
      end
    end
  end
end
