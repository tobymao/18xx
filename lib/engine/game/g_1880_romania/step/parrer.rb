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

          def process_presidents_percent_choice(action)
            percent = action.choice
            unless president_percent_choices.include?(percent)
              error_msg = "Invalid percentage (#{percent}). " \
                          "Choices are #{president_percent_choices.values.join(',')}."
              raise GameError, error_msg
            end

            corporation = @parring[:corporation]
            verb = corporation == @game.tr ? 'receives' : 'selects'
            @log << "#{@parring[:entity].name} #{verb} #{percent}% presidency share"

            if percent != corporation.presidents_percent
              num_to_remove = (percent - corporation.presidents_percent) / corporation.share_percent
              shares_to_remove = corporation.shares.select { |s| s.buyable && !s.president }.pop(num_to_remove)
              shares_to_remove.each { |s| corporation.delete_share!(s) }
              corporation.presidents_share.percent = percent
            end

            @parring[:state] = :choose_permit
            permit_choices = @game.building_permit_choices(corporation)
            return if permit_choices.size > 1

            process_building_permit_choice(Action::Choose.new(@parring[:entity], choice: permit_choices.first))
          end

          def process_building_permit_choice(action)
            permit = action.choice
            unless @game.building_permit_choices(@parring[:corporation]).include?(permit)
              error_msg = "Invalid building permit (#{permit}). " \
                          "Choices are #{@game.building_permit_choices(@parring[:corporation]).join(',')}."
              raise GameError, error_msg
            end

            @log << if @parring[:corporation] == @game.tr
                      "#{@parring[:corporation].name} is automatically assigned an #{permit} building permit"
                    else
                      "#{@parring[:entity].name} selects #{permit} building permit"
                    end

            @parring[:corporation].building_permits = action.choice

            @parring[:state] = :par_corporation
            process_par(Action::Par.new(@parring[:entity], corporation: @parring[:corporation],
                                                           share_price: @parring[:share_price]))
          end
        end
      end
    end
  end
end
