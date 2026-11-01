# frozen_string_literal: true

require_relative '../../../step/special_choose'

module Engine
  module Game
    module G18Junta
      module Step
        # Rules summary 11: the choose_ability privates.
        # (D) Ferramenteria Ochoa: once per game, when buying a train from the supply, discard a 2- or
        #     3-train and pay only the difference.
        # (E) Casa Ruiz de Assistencia: from the first 3-train, the owner may donate it to a company they
        #     preside over; the bank gives that company $150.
        # (N) Emisarios de las Sombras: once per game, remove a paramilitary token from the board; the
        #     president takes 2 black corruption tokens from the stock.
        class SpecialChoose < Engine::Step::SpecialChoose
          def choices_ability(entity)
            case entity.sym
            when '(D)' then private_d_choices(entity.owner)
            when '(E)' then private_e_choices(current_entity)
            when '(N)' then @game.remaining_paramilitary_hexes.to_h { |hex| [hex, "Remove the paramilitary token at #{hex}"] }
            else {}
            end
          end

          def process_choose_ability(action)
            entity = action.entity
            raise GameError, "#{entity.name} cannot do that now" unless choices_ability(entity).key?(action.choice)

            case entity.sym
            when '(D)'
              ability = abilities(entity)
              @game.exchange_train_for_private_d!(entity.owner, entity.owner.trains.find { |t| t.id == action.choice })
              ability.use!
            when '(E)'
              @game.donate_private_e!(current_entity)
            when '(N)'
              abilities(entity).use!
              @game.use_private_n!(entity.owner, action.choice)
            end
          end

          private

          def private_d_choices(corporation)
            target = @game.private_d_target_train
            return {} unless target

            corporation.trains.select { |t| %w[2 3].include?(t.name) && t.price < target.price }.to_h do |train|
              price = @game.format_currency(target.price - train.price)
              [train.id, "Discard a #{train.name}-train to buy a #{target.name}-train for #{price}"]
            end
          end

          def private_e_choices(corporation)
            return {} unless @game.private_e_donatable?(corporation)

            fee = @game.format_currency(@game.class::PRIVATE_E_DONATION)
            { 'donate' => "Donate to #{corporation.name} (it receives #{fee} from the bank)" }
          end
        end
      end
    end
  end
end
