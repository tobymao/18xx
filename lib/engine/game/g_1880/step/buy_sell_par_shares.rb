# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'

module Engine
  module Game
    module G1880
      module Step
        class BuySellParShares < Engine::Step::BuySellParShares
          def actions(entity)
            return ['choose'] if @parring && entity == current_entity

            actions = super.dup
            if @game.player_debt(entity).positive?
              actions.delete('buy_shares')
              actions << 'payoff_player_debt' if entity.cash.positive?
            end

            actions
          end

          def can_sell?(entity, bundle)
            return false if @game.communism && entity == bundle.corporation.owner

            super
          end

          def choice_available?(entity)
            @parring && entity == current_entity
          end

          def choice_name
            return nil unless @parring

            case @parring[:state]
            when :choose_percent
              'Choose presidency percent'
            when :choose_permit
              'Choose building permit'
            end
          end

          def choices
            return nil unless @parring

            case @parring[:state]
            when :choose_percent
              president_percent_choices
            when :choose_permit
              @game.building_permit_choices(@parring[:corporation])
            end
          end

          def president_percent_choices
            max_shares = (@parring[:entity].cash.to_f / @parring[:share_price].price).floor
            max_percent = max_shares * @parring[:corporation].share_percent
            { 20 => '20%', 30 => '30%', 40 => '40%' }.select { |k, _v| k <= max_percent }
          end

          def process_choose(action)
            case @parring[:state]
            when :choose_percent
              process_presidents_percent_choice(action)
            when :choose_permit
              process_building_permit_choice(action)
            else
              raise GameError, 'No choices to make at this time'
            end
          end

          def process_presidents_percent_choice(action)
            percent = action.choice
            unless president_percent_choices.include?(percent)
              error_msg = "Invalid percentage (#{percent}). " \
                          "Choices are #{president_percent_choices.values.join(',')}."
              raise GameError, error_msg
            end

            @log << "#{@parring[:entity].name} selects #{percent}% presidency share"
            corporation = @parring[:corporation]
            if percent != corporation.presidents_percent
              num_to_remove = (percent - corporation.presidents_percent) / corporation.share_percent
              shares_to_remove = corporation.shares.select { |s| s.buyable && !s.president }.pop(num_to_remove)
              shares_to_remove.each { |s| corporation.shares.delete(s) }
              corporation.presidents_share.percent = percent
            end

            @parring[:state] = :choose_permit
            permit_choices = @game.building_permit_choices(@parring[:corporation])
            return if permit_choices.size > 1

            process_building_permit_choice(Action::Choose.new(@parring[:entity], permit_choices.first))
          end

          def process_building_permit_choice(action)
            permit = action.choice
            unless @game.building_permit_choices(@parring[:corporation]).include?(permit)
              error_msg = "Invalid building permit (#{permit}). " \
                          "Choices are #{@game.building_permit_choices(@parring[:corporation]).join(',')}."
              raise GameError, error_msg
            end

            @log << "#{@parring[:entity].name} selects #{permit} building permit"
            @parring[:corporation].building_permits = action.choice

            @parring[:state] = :par_corporation
            process_par(Action::Par.new(@parring[:entity], corporation: @parring[:corporation],
                                                           share_price: @parring[:share_price]))
          end

          def process_par(action)
            if @parring
              @parring = nil
              return super
            end

            @parring = {
              state: :choose_percent,
              corporation: action.corporation,
              share_price: action.share_price,
              entity: action.entity,
            }
            percent_choices = president_percent_choices
            return if percent_choices.size > 1

            process_presidents_percent_choice(Action::Choose.new(@parring[:entity], choice: percent_choices.keys.first))
          end

          def process_buy_shares(action)
            super
            @game.receive_capital(action.corporation) if @game.full_cap_event
          end

          def process_payoff_player_debt(action)
            player = action.entity
            @game.payoff_player_loan(player)
            @round.last_to_act = player
            @round.current_actions << action
          end
        end
      end
    end
  end
end
