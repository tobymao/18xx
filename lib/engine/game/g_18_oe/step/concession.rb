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
            return "#{prefix}you cannot float a minor or afford a regional, so par a regional for any player to float later" if
              must_par_only?(current_entity)

            text = "#{prefix}float a minor you own or a regional you can afford"
            can_float_minor?(current_entity) ? "#{text}. #{super}" : text
          end

          def must_par_only?(player)
            player.companies.none? { |company| @game.company_becomes_minor?(company) } &&
              @game.corporations.none? { |corporation| parrable_regional?(player, corporation) }
          end

          def get_par_prices(entity, corporation)
            return @game.stock_market.par_prices if corporation.type == :regional && must_par_only?(entity)

            super
          end

          def par_price_only(corporation, _share_price)
            corporation.type == :regional && must_par_only?(current_entity)
          end

          def process_par(action)
            concession = @round.current_concession
            if action.corporation.type == :regional && must_par_only?(action.entity)
              par_only!(action)
            else
              super
            end
            @log << "#{action.entity.name} executes the #{concession.name}"
            concession.close!
            pass!
          end

          private

          def parrable_regional?(player, corporation)
            corporation.type == :regional && @game.can_par?(corporation, player) &&
              affordable_regional_par_prices(player).any?
          end

          def par_only!(action)
            player = action.entity
            corporation = action.corporation
            share_price = action.share_price
            raise GameError, "#{corporation.name} cannot be parred" unless @game.can_par?(corporation, player)
            unless get_par_prices(player, corporation).include?(share_price)
              raise GameError, "#{share_price.price} is not a par price"
            end

            @game.par_corporation(corporation, share_price)
            corporation.ipoed = true
            @game.minor_regional_order << corporation
            @log << "#{player.name} pars #{corporation.name} at #{@game.format_currency(share_price.price)}"
            track_action(action, corporation)
            close_unfloated_regionals_at_maximum!
          end
        end
      end
    end
  end
end
