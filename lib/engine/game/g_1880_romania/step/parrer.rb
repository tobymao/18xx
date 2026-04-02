# frozen_string_literal: true

module Engine
  module Game
    module G1880Romania
      module Step
        module Parrer
          def president_percent_choices
            max_shares = (@parring[:entity].cash.to_f / @parring[:share_price].price).floor
            max_percent = @parring[:corporation] == @game.tr ? 20 : max_shares * @parring[:corporation].share_percent
            { 20 => '20%', 30 => '30%', 40 => '40%' }.select { |k, _v| k <= max_percent }
          end

          def get_par_prices(entity, _corp)
            @game.stock_market.par_prices
              .select { |p| p.price * 2 <= entity.cash }
              .select { |p| @game.par_chart[p].include?(nil) }
          end

          def setup_par_choices(action)
            share_price = action.share_price
            slot = action.slot
            entity = action.entity
            corp = action.corporation

            unless @game.loading
              raise GameError, 'Par slot already taken' if @game.par_chart[share_price][slot]

              unless get_par_prices(entity, corp).include?(share_price)
                raise GameError, "#{entity.name} does not have enough cash (#{@game.format_currency(entity.cash)} to par at" \
                                 "#{format_currency(share_price.price)}"
              end
            end

            @game.set_par(corp, share_price, slot)
            @log << "#{entity.name} selects par #{@game.format_currency(share_price.price)} (slot #{slot}) for #{corp.name}"

            @parring = {
              state: :choose_percent,
              corporation: corp,
              share_price: share_price,
              entity: entity,
            }
            percent_choices = president_percent_choices
            return if percent_choices.size > 1

            process_presidents_percent_choice(Action::Choose.new(@parring[:entity], choice: percent_choices.keys.first))
          end
        end
      end
    end
  end
end
