# frozen_string_literal: true

module Engine
  module Game
    module G18ZOO
      module ChooseAbilityOnOr
        def can_choose_ability_on_any_step(corporation, company)
          return true if @game.zoo_ticket?(company) && company.owner == corporation.owner
          return true if company == @game.patch && @game.can_use_bandage?(corporation, company)

          false
        end

        def can_choose_any_ability_on_any_step?(entity)
          return false unless entity.corporation?

          return true if @game.zoo_tickets?(entity.owner)
          return true if @game.can_use_bandage?(entity, @game.patch)

          false
        end

        def choices_ability(company)
          corporation = @game.current_entity
          return choices_for_zoo_ticket(company, corporation) if @game.zoo_ticket?(company)

          return choices_for_two_barrels?(company.owner) if company == @game.two_barrels
          return @game.choices_for_bandage?(corporation) if company == @game.patch

          {}
        end

        def process_choose_ability(action)
          process_choose_zoo_ticket(action) if action.choice['type'] == 'sell'
          process_choose_two_barrels?(action) if action.choice['type'] == 'two_barrels'
          @game.process_choose_bandage?(action) if action.choice['type'] == 'patch'
          @game.process_remove_bandage?(action) if action.choice['type'] == 'remove_bandage'
        end

        private

        def choices_for_zoo_ticket(company, corporation)
          return [] unless company.owner == corporation.owner

          [*1..company.value].to_h do |value|
            [
              { type: :sell, price: value, corporation: corporation.id },
              "Company gets #{@game.format_currency(value)}; #{@game.format_currency(company.value - value)} to Player",
            ]
          end
        end

        def choices_for_two_barrels?(_corporation)
          { { type: :two_barrels } => "#{@game.two_barrels.all_abilities[0].count == 2 ? 'First' : 'Last'} barrel" }
        end

        def process_choose_zoo_ticket(action)
          company = action.entity
          player = company.owner
          corporation = @game.corporation_by_id(action.choice['corporation'])
          price_for_corporation = action.choice['price']
          price_for_player = company.value - price_for_corporation

          @log << "-- #{corporation.name} sells #{company.name} (owned by #{player.name}) "\
                  "for #{@game.format_currency(company.value)} --"

          if price_for_player.positive?
            @game.bank.spend(price_for_player, player)
            @log << "#{player.name} earns #{@game.format_currency(price_for_player)}"
          end

          @game.bank.spend(price_for_corporation, corporation)
          @log << "#{corporation.name} earns #{@game.format_currency(price_for_corporation)}"

          company.close!
        end

        def process_choose_two_barrels?(_action)
          @game.two_barrels.all_abilities[0].use!
          @log << "#{@game.two_barrels.owner.name} uses '#{@game.two_barrels.name}' for this round"

          @game.two_barrels.owner.assign!('BARREL')
        end
      end
    end
  end
end
