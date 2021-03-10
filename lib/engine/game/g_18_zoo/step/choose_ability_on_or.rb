# frozen_string_literal: true

module Engine
  module Game
    module G18ZOO
      module ChooseAbilityOnOr
        private

        def can_choose_ability_on_any_step(corporation, company)
          # p "can_choose_ability_on_any_step?(#{company.name} - #{corporation.name})" # TODO: use for debug
          return true if @game.zoo_ticket?(company) && company.owner == corporation.owner
          return true if company == @game.rabbits && can_choose_rabbits?(corporation)
          return true if company == @game.moles && can_choose_moles?(corporation)
          return true if company == @game.ancient_maps && can_choose_ancient_maps?(corporation)
          return true if company == @game.hole && can_choose_hole?(corporation)
          return true if company == @game.on_diet && can_choose_on_diet?(corporation)
          return true if company == @game.that_is_mine && can_choose_is_mine?(corporation)
          return true if company == @game.work_in_progress && can_choose_work_in_progress?(corporation)
          return true if company == @game.corn && can_choose_corn?(corporation)
          return true if company == @game.bandage && can_choose_bandage?(corporation)

          false
        end

        def choices_ability(company)
          return choices_for_zoo_ticket(company) if @game.zoo_ticket?(company)
          return choices_for_rabbits(company.owner) if company == @game.rabbits
          return choices_for_moles?(company.owner) if company == @game.moles
          return choices_for_ancient_maps?(company.owner) if company == @game.ancient_maps
          return choices_for_hole?(company.owner) if company == @game.hole
          return choices_for_on_diet?(company.owner) if company == @game.on_diet
          return choices_for_is_mine(company.owner) if company == @game.that_is_mine
          return choices_for_work_in_progress?(company.owner) if company == @game.work_in_progress
          return choices_for_corn?(company.owner) if company == @game.corn
          return choices_for_two_barrels?(company.owner) if company == @game.two_barrels
          return choices_for_bandage?(company.owner) if company == @game.bandage
          return choices_for_wings?(company.owner) if company == @game.wings
          return choices_for_sugar(company.owner) if company == @game.a_spoonful_of_sugar

          {}
        end

        def process_choose_ability(action)
          process_choose_zoo_ticket(action) if action.choice['type'] == 'sell'
          process_choose_rabbits(action) if action.choice['type'] == 'rabbits'
          process_choose_moles?(action) if action.choice['type'] == 'moles'
          process_choose_ancient_maps?(action) if action.choice['type'] == 'ancient_maps'
          process_choose_hole?(action) if action.choice['type'] == 'hole'
          process_choose_on_diet?(action) if action.choice['type'] == 'on_diet'
          process_choose_is_mine(action) if action.choice['type'] == 'that_is_mine'
          process_choose_work_in_progress?(action) if action.choice['type'] == 'work_in_progress'
          process_choose_corn?(action) if action.choice['type'] == 'corn'
          process_choose_two_barrels?(action) if action.choice['type'] == 'two_barrels'
          process_choose_bandage?(action) if action.choice['type'] == 'bandage'
          process_choose_wings?(action) if action.choice['type'] == 'wings'
          process_choose_sugar(action) if action.choice['type'] == 'sugar'
        end

        # TODO: add additional logic
        def can_choose_rabbits?(entity)
          @game.rabbits.owner == entity
        end

        # TODO: add additional logic
        def can_choose_moles?(entity)
          @game.moles.owner == entity
        end

        # TODO: add additional logic
        def can_choose_ancient_maps?(entity)
          @game.ancient_maps.owner == entity
        end

        # TODO: add additional logic
        def can_choose_hole?(entity)
          @game.hole.owner == entity
        end

        # TODO: add additional logic
        def can_choose_on_diet?(entity)
          @game.on_diet.owner == entity
        end

        # TODO: add additional logic
        def can_choose_is_mine?(entity)
          @game.that_is_mine.owner == entity
        end

        # TODO: add additional logic
        def can_choose_work_in_progress?(entity)
          @game.work_in_progress.owner == entity
        end

        # TODO: add additional logic
        def can_choose_corn?(entity)
          @game.corn.owner == entity
        end

        # TODO: add additional logic
        def can_choose_two_barrels?(entity)
          @game.two_barrels.owner == entity &&
            @game.two_barrels.all_abilities[0].count_this_or.zero?
        end

        # TODO: add additional logic
        def can_choose_bandage?(entity)
          @game.bandage.owner == entity
        end

        # TODO: add additional logic
        def can_choose_wings?(entity)
          @game.wings.owner == entity
        end

        # TODO: add additional logic
        def can_choose_sugar?(corporation)
          @game.a_spoonful_of_sugar.owner == corporation &&
            corporation.trains.any? { |train| !%w[2J 4J].include? train.name } &&
            corporation.all_abilities.none? { |a| a.type == :add_step_to_train }
        end

        def choices_for_zoo_ticket(company)
          corporation = @game.current_entity
          name = company.owner.name
          [*1..company.value].map do |value|
            [
              { type: :sell, price: value, company: company.id, corporation: corporation.id },
              "Sells for #{@game.format_currency(value)}; #{@game.format_currency(company.value - value)} to #{name}",
            ]
          end.to_h
        end

        def choices_for_rabbits(_corporation)
          ability = @game.rabbits.all_abilities[0]
          choices = {}
          choices[{ type: :rabbits }] = 'First upgrade' if ability.count == 2
          choices[{ type: :rabbits }] = 'Second upgrade' if ability.count == 1
        end

        # TODO: add logic
        def choices_for_moles?(_corporation)
          {}
        end

        # TODO: add logic
        def choices_for_ancient_maps?(_corporation)
          {}
        end

        # TODO: add logic
        def choices_for_hole?(_corporation)
          {}
        end

        # TODO: add logic
        def choices_for_on_diet?(_corporation)
          {}
        end

        # TODO: add logic
        def choices_for_is_mine(_corporation)
          {}
        end

        # TODO: add logic
        def choices_for_work_in_progress?(_corporation)
          {}
        end

        # TODO: add logic
        def choices_for_corn?(_corporation)
          {}
        end

        # TODO: add logic
        def choices_for_two_barrels?(_corporation)
          {}
        end

        # TODO: add logic
        def choices_for_bandage?(_corporation)
          {}
        end

        # TODO: add logic
        def choices_for_wings?(_corporation)
          {}
        end

        def choices_for_sugar(_corporation)
          corporation.trains
                     .reject { |train| %w[2J 4J].include? train.name }
                     .map { |train| [{ type: :sugar, train_id: train.id }, train.name] }
                     .to_h
        end

        def process_choose_zoo_ticket(action)
          company = @game.company_by_id(action.choice['company'])
          player = company.owner
          corporation = @game.corporation_by_id(action.choice['corporation'])
          price_for_corporation = action.choice['price']
          price_for_player = company.value - price_for_corporation

          @log << "-- #{corporation.name} sells #{company.name} (owned by #{player.name}) "\
            "for #{@game.format_currency(company.value)} --"

          @game.bank.spend(price_for_player, player) if price_for_player.positive?
          @log << "#{player.name} earns #{@game.format_currency(price_for_player)}" if price_for_player.positive?

          @game.bank.spend(price_for_corporation, corporation)
          @log << "#{corporation.name} earns #{@game.format_currency(price_for_corporation)}"

          company.close!
        end

        def process_choose_rabbits(_action)
          ability = @game.rabbits.all_abilities[0]
          ability.count_this_or = 1
        end

        # TODO: add logic
        def process_choose_moles?(_action) end

        # TODO: add logic
        def process_choose_ancient_maps?(_action) end

        # TODO: add logic
        def process_choose_hole?(_action) end

        # TODO: add logic
        def process_choose_on_diet?(_action) end

        # TODO: add logic
        def process_choose_is_mine(_action) end

        # TODO: add logic
        def process_choose_work_in_progress?(_action) end

        # TODO: add logic
        def process_choose_corn?(_action) end

        # TODO: add logic
        def process_choose_two_barrels?(_action) end

        # TODO: add logic
        def process_choose_bandage?(_action) end

        # TODO: add logic
        def process_choose_wings?(_action) end

        # TODO: add logic
        def process_choose_sugar(_action)
          # train = @game.train_by_id(action.choice[:train_id])
          # company = @game.a_spoonful_of_sugar
          # corporation = company.owner
          # ability = Engine::G18ZOO::Ability::AddStepToTrain.new(type: 'add_step_to_train', train: train,
          # description: "Train #{train.name} can do 1 step more")
          # corporation.add_ability(ability)
        end
      end
    end
  end
end
