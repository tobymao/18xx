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
          return true if company == @game.midas && can_choose_midas?(entity)
          return true if company == @game.days_off && can_choose_days_off?(entity)
          return true if company == @game.whatsup && can_choose_whatsup?(entity)
          return true if company == @game.it_is_all_greek_to_me && can_choose_greek?(entity)

          false
        end

        def can_choose_any_ability?(entity)
          return false unless entity.player?

          return true if @game.zoo_tickets?(entity)
          return true if @game.midas.owner == entity && can_choose_midas?(entity)
          return true if @game.days_off.owner == entity && can_choose_days_off?(entity)
          return true if @game.whatsup.owner == entity && can_choose_whatsup?(entity)
          return true if @game.it_is_all_greek_to_me.owner == entity && can_choose_greek?(entity)

          false
        end

        def choices_ability(company)
          return choices_for_zoo_ticket(company) if @game.zoo_ticket?(company)
          return choices_for_midas if company == @game.midas
          return choices_for_days_off if company == @game.days_off
          return choices_for_whatsup(company.owner) if company == @game.whatsup
          return choices_for_greek if company == @game.it_is_all_greek_to_me

          {}
        end

        def process_choose_ability(action)
          process_choose_zoo_ticket(action) if action.choice['type'] == 'sell'
          process_midas(action) if action.choice['type'] == 'midas'
          process_days_off(action) if action.choice['type'] == 'days_off'
          process_whatsup(action) if action.choice['type'] == 'whatsup'
          process_greek(action) if action.choice['type'] == 'greek'
        end

        def can_choose_midas?(_player)
          !@game.midas_active?
        end

        def can_choose_days_off?(_player)
          @game.corporations.any?(&:ipoed)
        end

        def can_choose_whatsup?(player)
          player.presidencies.any? do |corp|
            corp.cash >= @game.depot.depot_trains&.first&.price &&
              corp.trains.count { |t| !t.obsolete } < @game.phase.train_limit(corp)
          end
        end

        def can_choose_greek?(_player)
          (@round.floated_corporation || bought? || sold?) &&
            !@game.greek_to_me_active?
        end

        def choices_for_zoo_ticket(company)
          { { type: :sell } => "Sell for #{@game.format_currency(company.value)}" }
        end

        def choices_for_midas
          { { type: :midas } => "Priority for #{@game.midas.owner.name}" }
        end

        def choices_for_days_off
          @game.corporations.select(&:ipoed)
               .to_h { |corporation| [{ type: :days_off, corporation_id: corporation.id }, corporation.name] }
        end

        def choices_for_whatsup(player)
          train = @game.depot.depot_trains&.first
          player.presidencies
                .select { |c| c.cash >= train&.price }
                .to_h { |c| [{ type: :whatsup, corporation_id: c.id, train_id: train.id }, c.name] }
        end

        def choices_for_greek
          { { type: :greek } => 'Play another round after this' }
        end

        def process_choose_zoo_ticket(action)
          company = action.entity
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

        def process_days_off(action)
          corporation = @game.corporation_by_id(action.choice['corporation_id'])
          current_value = corporation.share_price.price
          @game.stock_market.move_right(corporation)
          new_value = corporation.share_price.price
          @log << "-- #{current_entity.name} uses \"Days off\" for #{corporation.name}, "\
                  "moving from #{@game.format_currency(current_value)} to #{@game.format_currency(new_value)} --"

          @game.days_off.close!
        end

        def process_whatsup(action)
          corporation = @game.corporation_by_id(action.choice['corporation_id'])
          train = @game.train_by_id(action.choice['train_id'])
          source = train.owner
          @game.buy_train(corporation, train, train.price)
          @game.phase.buying_train!(corporation, train, source)

          ability = Engine::G18ZOO::Ability::DisableTrain.new(
            type: 'disable_train', train: train,
            description: "Whatsup: #{train.id} disabled",
            desc_detail: "Train #{train.id} got using \"Whatsup\"; disabled for the next OR"
          )
          corporation.add_ability(ability)

          @log << "#{current_entity.name} uses \"Whatsup\" for #{corporation.name}, "\
                  "paying #{@game.format_currency(train.price)} to buy a #{train.name}"

          old_price = corporation.share_price
          @game.stock_market.move_right(corporation)
          @game.log_share_price(corporation, old_price, '(whatsup bonus)')

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
