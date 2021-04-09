# frozen_string_literal: true

module Engine
  module Game
    module G18ZOO
      module ChooseAbilityOnOr
        # TODO: add all commented choice later
        def can_choose_ability_on_any_step(corporation, company)
          return true if @game.zoo_ticket?(company) && company.owner == corporation.owner

          # return true if company == @game.that_is_mine && can_choose_is_mine?(corporation)
          # return true if company == @game.work_in_progress && can_choose_work_in_progress?(corporation)
          # return true if company == @game.bandage && can_choose_bandage?(corporation)

          false
        end

        # TODO: add all commented choice later
        def can_choose_any_ability_on_any_step?(entity)
          return false unless entity.corporation?

          return true if @game.zoo_tickets?(entity.owner)

          # return can_choose_...

          false
        end

        # TODO: add all commented choice later
        def choices_ability(company)
          corporation = @game.current_entity
          return choices_for_zoo_ticket(company, corporation) if @game.zoo_ticket?(company)

          # return choices_for_is_mine(company.owner) if company == @game.that_is_mine
          # return choices_for_work_in_progress?(company.owner) if company == @game.work_in_progress
          return choices_for_two_barrels?(company.owner) if company == @game.two_barrels
          # return choices_for_bandage?(company.owner) if company == @game.bandage
          # return choices_for_wings?(company.owner) if company == @game.wings
          return choices_for_sugar(company.owner) if company == @game.a_spoonful_of_sugar

          {}
        end

        # TODO: add all commented choice later
        def process_choose_ability(action)
          process_choose_zoo_ticket(action) if action.choice['type'] == 'sell'
          # process_choose_is_mine(action) if action.choice['type'] == 'that_is_mine'
          # process_choose_work_in_progress?(action) if action.choice['type'] == 'work_in_progress'
          process_choose_two_barrels?(action) if action.choice['type'] == 'two_barrels'
          # process_choose_bandage?(action) if action.choice['type'] == 'bandage'
          # process_choose_wings?(action) if action.choice['type'] == 'wings'
          process_choose_sugar(action) if action.choice['type'] == 'sugar'
        end

        private

        # TODO: add additional logic
        # def can_choose_is_mine?(entity)
        #   @game.that_is_mine.owner == entity
        # end

        # TODO: add additional logic
        # def can_choose_work_in_progress?(entity)
        #   @game.work_in_progress.owner == entity
        # end

        # TODO: add additional logic
        # def can_choose_bandage?(entity)
        #   @game.bandage.owner == entity
        # end

        # TODO: add additional logic
        # def can_choose_wings?(entity)
        #   @game.wings.owner == entity
        # end

        def choices_for_zoo_ticket(company, corporation)
          return [] unless company.owner == corporation.owner

          name = company.owner.name
          [*1..company.value].map do |value|
            [
              { type: :sell, price: value, corporation: corporation.id },
              "Sells for #{@game.format_currency(value)}; #{@game.format_currency(company.value - value)} to #{name}",
            ]
          end.to_h
        end

        # TODO: add logic
        # def choices_for_is_mine(_corporation)
        #   {}
        # end

        # TODO: add logic
        # def choices_for_work_in_progress?(_corporation)
        #   {}
        # end

        def choices_for_two_barrels?(_corporation)
          { { type: :two_barrels } => "#{@game.two_barrels.all_abilities[0].count == 2 ? 'First' : 'Last'} barrel" }
        end

        # TODO: add logic
        # def choices_for_bandage?(_corporation)
        #   {}
        # end

        # TODO: add logic
        # def choices_for_wings?(_corporation)
        #   {}
        # end

        # TODO: add logic for 'Bandage'
        # Not available for 2J / 4J, or if train has the 'Bandage'
        def choices_for_sugar(corporation)
          corporation.trains
                     .reject { |train| %w[2J 4J].include?(train.name) }
                     .map { |train| [{ type: :sugar, train_id: train.id }, train.name] }
                     .to_h
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

        # TODO: add logic
        # def process_choose_is_mine(_action) end

        # TODO: add logic
        # def process_choose_work_in_progress?(_action) end

        def process_choose_two_barrels?(_action)
          @game.two_barrels.all_abilities[0].use!
          @log << "#{@game.two_barrels.owner.name} uses '#{@game.two_barrels.name}' for this round"

          @game.two_barrels.owner.assign!('BARREL')
        end

        # TODO: add logic
        # def process_choose_bandage?(_action) end

        # TODO: add logic
        # def process_choose_wings?(_action) end

        def process_choose_sugar(action)
          train = @game.train_by_id(action.choice['train_id'])
          company = @game.a_spoonful_of_sugar
          corporation = company.owner
          ability = Engine::G18ZOO::Ability::IncreaseDistanceForTrain.new(
            type: 'increase_distance_for_train', train: train, distance: 1,
            description: "Train #{train.name} can do 1 step more"
          )
          corporation.add_ability(ability)
        end
      end
    end
  end
end
