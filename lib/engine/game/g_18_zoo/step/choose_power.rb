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
          if company_whatsup?(entity)
            train = @game.depot.depot_trains&.first
            entity.presidencies
                  .select { |corporation| corporation.cash >= @game.depot.depot_trains&.first&.price }
                  .each do |corporation|
              @choices["whatsup:#{corporation.id}:#{train.id}"] = "Whatsup (#{corporation.id}) (#{train.name})"
            end
          end
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
          entity&.companies&.include?(@game.whatsup) &&
            entity.presidencies.any? { |c| c.cash >= @game.depot.depot_trains&.first&.price }
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
            @log << "#{current_entity.name} uses \"Holiday\" for #{corporation.name}, "\
              "moving from #{@game.format_currency(current_value)} to #{@game.format_currency(new_value)}"

            @game.holiday.close!
          end

          if action.choice.start_with? 'whatsup:'
            split = action.choice.split(':')
            corporation = @game.corporation_by_id(split[1])
            train = @game.train_by_id(split[2])
            @game.buy_train(corporation, train, train.price)
            @game.phase.buying_train!(corporation, train)

            ability = Engine::Ability::Close.new(type: 'train_operated', corporation: train,
                                                 description: "Whatsup - #{split[2]} disabled")
            corporation.add_ability(ability)

            prev = corporation.share_price.price
            @game.stock_market.move_right(corporation)
            @game.log_share_price(corporation, prev, '(whatsup bonus)')

            @log << "#{current_entity.name} uses \"Whatsup\" for #{corporation.name}, "\
              "paying #{@game.format_currency(train.price)} to buy a #{train.name}"

            @game.whatsup.close!
          end

          return unless action.choice == 'greek_to_me'

          @game.it_s_all_greek_to_me.add_ability(Engine::Ability::Close.new(type: 'close'))
          @log << "#{current_entity.name} uses \"It’s all greek to me\", "\
            'will get an additional round after passing this round'
        end
      end
    end
  end
end
