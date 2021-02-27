# frozen_string_literal: true

module Engine
  module Game
    module G18ZOO
      module ChoosePower
        def choice_name
          'Use powers'
        end

        def choices
          entity = current_entity
          @choices = {}
          @choices[:midas] = 'Midas' if company_midas?(entity)
          if company_holiday?(entity)
            @game.corporations.select(&:ipoed).each do |corporation|
              @choices["holiday:#{corporation.id}"] = "Holiday (#{corporation.id})"
            end
          end
          @choices[:greek_to_me] = 'It’s all greek to me' if company_greek?(entity)
          @choices[:whatsup] = 'Whatsup' if company_whatsup?(entity)
          @choices
        end

        def choice_available?(entity)
          company_midas?(entity) || company_holiday?(entity) || company_whatsup?(entity) || company_greek?(entity)
        end

        def company_midas?(entity)
          entity&.companies&.include?(@game.midas) &&
            @game.midas.all_abilities.none? { |ability| ability.is_a?(Engine::Ability::Close) }
        end

        def company_holiday?(entity)
          entity&.companies&.include?(@game.holiday) &&
            @game.corporations.any?(&:ipoed)
        end

        def company_whatsup?(entity)
          entity&.companies&.include?(@game.whatsup)
        end

        def company_greek?(entity)
          entity&.companies&.include?(@game.it_s_all_greek_to_me) &&
            (@round.floated_corporation || bought? || sold?) &&
            @game.it_s_all_greek_to_me.all_abilities.none? { |ability| ability.is_a?(Engine::Ability::Close) }
        end

        def process_choose(action)
          if action.choice == 'midas'
            @game.midas.add_ability(Engine::Ability::Close.new(type: 'close'))
            @log << "#{current_entity.name} uses \"Midas\", will get the Priority for the next SR"
          end

          if action.choice.start_with? 'holiday:'
            corporation = @game.corporation_by_id(action.choice.split(':')[1])
            current_value = corporation.share_price.price
            @game.stock_market.move_right(corporation)
            new_value = corporation.share_price.price
            @log << "#{current_entity.name} uses \"Holiday\" for #{corporation.name}, moving from #{current_value} to #{new_value}"

            @game.holiday.close!
          end

          if action.choice == 'whatsup'
            raise GameError, 'Power not yet implemented'
          end

          if action.choice == 'greek_to_me'
            @game.it_s_all_greek_to_me.add_ability(Engine::Ability::Close.new(type: 'close'))
            @log << "#{current_entity.name} uses \"It’s all greek to me\", will get an additional round after passing this round"
          end
        end
      end
    end
  end
end
