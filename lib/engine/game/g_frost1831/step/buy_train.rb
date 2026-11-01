# frozen_string_literal: true

require_relative '../../../step/buy_train'

module Engine
  module Game
    module GFrost1831
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          def can_entity_buy_train?(entity)
            return false if entity.type == :faction

            super
          end

          # In forced purchase (2nd favor this OR while trainless), the corp may
          # only buy from the depot — never from another player's corporation.
          def buyable_trains(entity)
            trains = super
            return trains unless @game.depot_only_train_purchase?(entity)

            trains.select(&:from_depot?)
          end

          def log_skip(entity)
            return if entity.type == :faction

            super
          end

          def choice_name
            nil
          end

          # Accept choose action for FAVOR company and diamond upgrades
          def actions(entity)
            return %w[choose] if entity&.company? && entity.sym == 'FAV'

            # Assign FAV to current corp if parliament is open and corp can request favor
            if entity == current_entity && entity&.corporation? && entity.type != :faction
              if @game.parliament_open? &&
                 @game.can_request_favor?(entity) &&
                 !entity.companies.include?(@game.favor_company)
                @game.assign_favor_to_current_operator(entity)
              end
            end

            acts = super

            # If must buy but engine returned empty (can't afford, no ebuy) → force buy_train action
            if acts.empty? && entity == current_entity && @game.must_buy_train?(entity)
              acts = %w[buy_train]
            end

            # If corp can't buy trains but CAN upgrade to diamond, keep the step active
            if acts.empty? &&
               entity == current_entity &&
               !entity&.company? &&
               entity.respond_to?(:trains) &&
               @game.can_upgrade_to_diamond?(entity)
              acts = %w[choose pass]
            end

            # If corp can buy trains AND upgrade to diamond, add choose
            if acts.include?('buy_train') &&
               !acts.include?('choose') &&
               @game.can_upgrade_to_diamond?(entity)
              acts = acts + ['choose']
            end

            # Never allow pass when must buy train
            acts.delete('pass') if acts.include?('buy_train') && @game.must_buy_train?(entity)

            acts
          end

          # Override: don't auto-pass if diamond upgrades are still available
          def process_buy_train(action)
            check_spend(action)
            buy_train_action(action)

            # Train events (Blizzard, close_companies, ...) have all run by now.
            # If the Blizzard eliminated the operating corporation, close it here
            # so the operating turn only advances after the whole resolution.
            @game.flush_pending_eliminations!

            pass! if !can_buy_train?(action.entity) &&
                     !@game.can_upgrade_to_diamond?(action.entity) &&
                     pass_if_cannot_buy_train?(action.entity)
          end

          def process_choose(action)
            # Handle FAVOR company choose
            if action.entity&.company? && action.entity.sym == 'FAV'
              special_choose = @round.steps.find { |s| s.is_a?(GFrost1831::Step::SpecialChoose) }
              special_choose&.process_choose_ability(action)
              return
            end

            # Handle diamond upgrade choice
            choice = action.choice
            return unless choice.start_with?('diamond_')

            parts = choice.split('_')
            # Format: diamond_<train_sym>-<train_index>_<faction_sym>
            train_id = parts[1]
            faction_sym = parts[2]

            train = @game.train_by_id(train_id)
            corporation = action.entity

            raise GameError, "Train #{train_id} not found" unless train
            raise GameError, "#{corporation.name} does not own #{train.name}" unless corporation.trains.include?(train)

            @game.upgrade_train_to_diamond!(corporation, train, faction_sym)

            # After upgrading, check if we should auto-pass
            pass! if !can_buy_train?(corporation) && !@game.can_upgrade_to_diamond?(corporation)
          end

          # Prevent the generic Choose view from rendering (diamond buttons are in buy_trains.rb)
          def render_choices?
            false
          end

          # Provide empty choices to prevent crash if generic Choose view is somehow invoked
          def choices
            {}
          end

          def ebuy_president_can_contribute?(_corporation)
            false
          end

          def president_may_contribute?(_entity, _shell = nil)
            false
          end

          def can_ebuy_sell_shares?(_entity)
            false
          end

          def pass_if_cannot_buy_train?(entity)
            # Don't auto-pass if diamond upgrades are available
            return false if @game.can_upgrade_to_diamond?(entity)

            !@game.must_buy_train?(entity)
          end

          def diamond_upgrades_allowed?(_corporation)
            true
          end

          # Generic hook: provides data for the buy_trains view to render upgrade buttons
          def extra_train_exchanges(corporation)
            return [] unless @game.can_upgrade_to_diamond?(corporation)

            exchanges = []
            shown_types = {}

            @game.upgradeable_to_diamond(corporation).each do |train, factions|
              base_name = train.name
              next if shown_types[base_name]

              shown_types[base_name] = true
              diamond_name = @game.class::DIAMOND_TRAINS[base_name]

              factions.each do |faction_sym|
                faction_label = @game.faction_display_name(faction_sym)
                exchanges << {
                  from: base_name,
                  to: diamond_name,
                  choice: "diamond_#{train.id}_#{faction_sym}",
                  label: "Influence by #{faction_label}",
                }
              end
            end

            exchanges
          end
        end
      end
    end
  end
end
