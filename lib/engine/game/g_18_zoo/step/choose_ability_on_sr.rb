# frozen_string_literal: true

module Engine
  module Game
    module G18ZOO
      module ChooseAbilityOnSr
        private

        def can_choose_ability?(company)
          entity = @game.current_entity
          return false unless entity.player?
          return false unless company.owner == entity

          return true if @game.zoo_ticket?(company)
          return can_choose_midas?(entity) if company == @game.midas
          return can_choose_holiday?(entity) if company == @game.holiday
          return can_choose_whatsup?(entity) if company == @game.whatsup
          return can_choose_greek?(entity) if company == @game.it_is_all_greek_to_me

          false
        end

        def can_choose_any_ability?(entity)
          return false unless entity.player?

          return true if @game.zoo_tickets?(entity)
          return can_choose_midas?(entity) if @game.midas.owner == entity
          return can_choose_holiday?(entity) if @game.holiday.owner == entity
          return can_choose_whatsup?(entity) if @game.whatsup.owner == entity
          return can_choose_greek?(entity) if @game.it_is_all_greek_to_me.owner == entity

          false
        end

        def choices_ability(company)
          return choices_for_zoo_ticket(company) if @game.zoo_ticket?(company)
          return choices_for_midas if company == @game.midas
          return choices_for_holiday if company == @game.holiday
          return choices_for_whatsup if company == @game.whatsup
          return choices_for_greek if company == @game.it_is_all_greek_to_me

          {}
        end

        def process_choose_ability(action)
          process_choose_zoo_ticket(action) if action.choice['type'] == 'sell'
          process_midas(action) if action.choice['type'] == 'midas'
          process_holiday(action) if action.choice['type'] == 'holiday'
          process_whatsup(action) if action.choice['type'] == 'whatsup'
          process_greek(action) if action.choice['type'] == 'greek'
        end

        def can_choose_midas?(_player)
          !@game.midas_active?
        end

        def can_choose_holiday?(_player)
          @game.corporations.any?(&:ipoed)
        end

        def can_choose_whatsup?(player)
          player.presidencies.any? { |c| c.cash >= @game.depot.depot_trains&.first&.price }
        end

        def can_choose_greek?(_player)
          (@round.floated_corporation || bought? || sold?) &&
            !@game.greek_to_me_active?
        end

        def choices_for_zoo_ticket(company)
          { { type: :sell, company: company.id } => "Sell for #{@game.format_currency(company.value)}" }
        end

        def choices_for_midas
          { { type: :midas } => "Priority for #{@game.midas.owner.name}" }
        end

        def choices_for_holiday
          @game.corporations.select(&:ipoed)
               .map { |corporation| [{ type: :holiday, corporation_id: corporation.id }, corporation.name] }
               .to_h
        end

        def choices_for_whatsup
          train = @game.depot.depot_trains&.first
          entity.presidencies
                .select { |c| c.cash >= train&.price }
                .map { |c| [{ type: :whatsup, corporation_id: c.id, train_id: train.id }, c.name] }
                .to_h
        end

        def choices_for_greek
          { { type: :greek } => 'Play another round after this' }
        end

        def process_choose_zoo_ticket(action)
          company = @game.company_by_id(action.choice['company'])
          price = company.value
          player = company.player

          @log << "-- #{player.name} sells #{company.name} for #{@game.format_currency(price)} --"

          @game.bank.spend(price, player)
          @log << "#{player.name} earns #{@game.format_currency(price)}"

          company.close!
        end

        def process_midas(_action)
          @game.midas.add_ability(Engine::Ability::Close.new(type: :close))
          @log << "-- #{current_entity.name} uses \"Midas\", will get the Priority for the next SR --"
        end

        def process_holiday(action)
          corporation = @game.corporation_by_id(action.choice['corporation_id'])
          current_value = corporation.share_price.price
          @game.stock_market.move_right(corporation)
          new_value = corporation.share_price.price
          @log << "-- #{current_entity.name} uses \"Holiday\" for #{corporation.name}, "\
                "moving from #{@game.format_currency(current_value)} to #{@game.format_currency(new_value)} --"

          @game.holiday.close!
        end

        def process_whatsup(action)
          corporation = @game.corporation_by_id(action.choice[:corporation_id])
          train = @game.train_by_id(action.choice[:train_id])
          @game.buy_train(corporation, train, train.price)
          @game.phase.buying_train!(corporation, train)

          ability = Engine::G18ZOO::Ability::DisableTrain.new(type: 'disable_train', train: train,
                                                              description: "Whatsup - #{train.id} disabled")
          corporation.add_ability(ability)

          prev = corporation.share_price.price
          @game.stock_market.move_right(corporation)
          @game.log_share_price(corporation, prev, '(whatsup bonus)')

          @log << "#{current_entity.name} uses \"Whatsup\" for #{corporation.name}, "\
                "paying #{@game.format_currency(train.price)} to buy a #{train.name}"

          @game.whatsup.close!
        end

        def process_greek(_action)
          @game.it_is_all_greek_to_me.add_ability(Engine::Ability::Close.new(type: :close))
          @log << "#{current_entity.name} uses \"It’s all greek to me\", "\
              'will get an additional round after passing this round'
        end
      end
    end
  end
end
