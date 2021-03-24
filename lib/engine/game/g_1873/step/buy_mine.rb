# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G1873
      module Step
        class BuyMine < Engine::Step::Base
          BUY_ACTIONS = %w[buy_corporation pass].freeze

          def actions(entity)
            return [] if entity != current_entity
            return [] unless @game.public_mine?(entity)
            return [] if entity.receivership?
            return [] unless @game.any_slot_available?(entity)

            BUY_ACTIONS
          end

          def skip!
            return super if @game.public_mine?(current_entity)

            pass!
          end

          def description
            'Buy Independent Mines'
          end

          def show_other_players
            false
          end

          def buyable_text(corporation)
            "Mines that can be bought by #{corporation.name}:"
          end

          def buyable_types
            'mines'
          end

          def buyable_entities(entity)
            @game.buyable_private_mines(entity)
          end

          def price_range(buyer, mine)
            if mine.owner
              [1, 2 * @game.mine_face_value(mine)]
            else
              [@game.mine_face_value(mine), [@game.mine_face_value(mine), buyer.cash].min]
            end
          end

          def buy_value(mine)
            mine.owner ? 1 : @game.mine_face_value(mine)
          end

          def process_buy_corporation(action)
            entity = action.entity
            mine = action.minor
            price = action.price

            raise GameError, 'no room for mine' unless @game.any_slot_available?(entity)
            if mine.owner && (!price.positive? || price > 2 * @game.mine_face_value(mine))
              raise GameError, "price must be between 1 and #{2 * @game.mine_face_value(mine)}"
            end
            if !mine.owner && price != @game.mine_face_value(mine)
              raise GameError, "price for closed mine must be face value: #{@game.mine_face_value(mine)}"
            end
            raise GameError, "#{entity.name} cannot afford price of #{price}" if price > entity.cash

            if mine.owner
              @log << "#{entity.id} buys #{mine.name} from #{mine.owner.name} for #{@game.format_currency(price)}"
              entity.spend(price, mine.owner)
            else
              @log << "#{entity.id} buys #{mine.name} from bank for #{@game.format_currency(price)}"
              entity.spend(price, @game.bank)
            end

            # buyer gets formerly independent mines and their cash
            # machines and switchers stay with mines
            @game.open_mine!(mine)
            @game.add_mine(entity, mine)

            pass!
          end
        end
      end
    end
  end
end
