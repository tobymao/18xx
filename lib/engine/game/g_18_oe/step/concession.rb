# frozen_string_literal: true

require_relative 'buy_sell_par_shares'

module Engine
  module Game
    module G18OE
      module Step
        class Concession < BuySellParShares
          def actions(entity)
            return [] if entity.corporation?
            return [] unless entity == current_entity

            ['par']
          end

          def description
            'Execute Concession'
          end

          def help
            prefix = "Executing the #{@round.current_concession.name}: "
            return "#{prefix}you cannot float a minor or afford a regional, so par a regional into the Open Market" if
              must_par_in_open_market?(current_entity)

            text = "#{prefix}float a minor you own or a regional you can afford"
            can_float_minor?(current_entity) ? "#{text}. #{super}" : text
          end

          def must_par_in_open_market?(player)
            player.companies.none? { |company| @game.company_becomes_minor?(company) } &&
              available_cash(player) < 2 * @game.lowest_regional_par_price
          end

          def get_par_prices(entity, corporation)
            return @game.stock_market.par_prices if corporation.type == :regional && must_par_in_open_market?(entity)

            super
          end

          def par_price_only(corporation, _share_price)
            corporation.type == :regional && must_par_in_open_market?(current_entity)
          end

          def process_par(action)
            concession = @round.current_concession
            if action.corporation.type == :regional && must_par_in_open_market?(action.entity)
              par_in_open_market!(action)
            else
              super
            end
            @log << "#{action.entity.name} executes the #{concession.name}"
            concession.close!
            pass!
          end

          private

          def par_in_open_market!(action)
            player = action.entity
            corporation = action.corporation
            share_price = action.share_price
            raise GameError, "#{corporation.name} cannot be parred" unless @game.can_par?(corporation, player)
            unless get_par_prices(player, corporation).include?(share_price)
              raise GameError, "#{share_price.price} is not a par price"
            end

            @game.par_regional_in_open_market!(corporation, share_price)
            @log << "#{player.name} pars #{corporation.name} at #{@game.format_currency(share_price.price)} into the Open Market"
            track_action(action, corporation)
            close_unfloated_regionals_at_maximum!
          end
        end
      end
    end
  end
end
