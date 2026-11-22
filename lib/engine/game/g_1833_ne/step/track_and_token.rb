# frozen_string_literal: true

require_relative '../../../item'
require_relative '../../../step/track_and_token'
require_relative 'receivership_skip'

module Engine
  module Game
    module G1833NE
      module Step
        class TrackAndToken < Engine::Step::TrackAndToken
          include ReceivershipSkip

          def setup
            super
            @ferry_bought = false
          end

          def actions(entity)
            actions = super
            return actions if entity != current_entity || entity.receivership? || !can_buy_ferry?(entity)

            actions - ['pass'] + %w[special_buy pass]
          end

          def buyable_items(entity)
            return [] if @ferry_bought

            @game.buyable_ferries(entity).map { |hex| ferry_item(hex) }
          end

          def process_special_buy(action)
            entity = action.entity
            hex = @game.ferry_hexes.find { |ferry_hex| ferry_item(ferry_hex) == action.item }
            if !hex || (!@game.loading && !buyable_items(entity).include?(action.item))
              raise GameError, "#{entity.name} cannot buy #{action.item.description}"
            end

            @game.buy_ferry!(entity, hex)
            @ferry_bought = true
            pass_if_done!(entity)
          end

          def process_place_token(action)
            place_token(action.entity, action.city, action.token)
            @tokened = true
            pass_if_done!(action.entity)
          end

          def process_lay_tile(action)
            lay_tile_action(action)

            if action.entity == @game.lowell_merchants_company&.owner && @game.lowell_merchants_company_activated
              @game.remove_lowell_merchants_ability!
            end

            lay_joint_tokens! if action.hex.id == @game.class::SHERBROOKE_HEX && action.tile.color == :yellow

            pass_if_done!(action.entity)
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

          private

          def can_buy_ferry?(entity)
            !buyable_items(entity).empty?
          end

          def pass_if_done!(entity)
            pass! if !can_lay_tile?(entity) && !can_place_token?(entity) && !can_buy_ferry?(entity)
          end

          def ferry_item(hex)
            Item.new(description: "#{@game.ferry_name(hex)} (#{hex.id})", cost: @game.ferry_cost)
          end
        end
      end
    end
  end
end
