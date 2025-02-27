# frozen_string_literal: true

require_relative '../../../round/operating'

module Engine
  module Game
    module G1841
      module Round
        class Operating < Engine::Round::Operating
          def setup
            @current_operator = nil
            @home_token_timing = @game.class::HOME_TOKEN_TIMING
            @entities.each { |c| @game.place_home_token(c) } if @home_token_timing == :operating_round
            @entities.each { |e| e.trains.each { |t| t.operated = false } }
            (@game.corporations + @game.minors + @game.companies).each(&:reset_ability_count_this_or!)
            @game.done_this_round.clear
            after_setup
          end

          def skip_entity?(entity)
            entity.closed? || @game.done_this_round[entity]
          end

          def after_process(action)
            return if action.type == 'message'

            @current_operator_acted = true if action.entity.corporation == @current_operator

            if active_step
              entity = @entities[@entity_index]
              control = @game.controller(entity)
              return if control&.player? || control&.share_pool?
            end

            after_end_of_turn(@current_operator)

            next_entity! unless @game.finished
          end

          def start_operating
            return if @game.finished

            entity = @entities[@entity_index]

            if @game.frozen?(entity)
              frozen_operation(entity)
              @steps.each(&:pass!)
            end

            super
          end

          def after_end_of_turn(entity)
            return unless entity&.corporation?

            @game.done_operating!(entity)
          end

          def frozen_operation(entity)
            @log << "Frozen operation for #{entity.name}"

            # move share price 2x to the left
            old_price = entity.share_price
            2.times { @game.stock_market.move_left(entity) }
            @game.log_share_price(entity, old_price, 2)

            return unless @game.circular?(entity)

            # for circular ownership, sell shares of corps that were in chain when it became frozen
            # circular will remain set as long as corp is frozen
            entity.corporate_shares.select { |s| @game.in_cicular_chain?(entity, s.corporation) }.each do |share|
              @game.sell_shares_and_change_price(share.to_bundle, allow_president_change: true)
            end
            @game.update_frozen!
          end
        end
      end
    end
  end
end
