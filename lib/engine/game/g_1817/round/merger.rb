# frozen_string_literal: true

require_relative '../../../round/merger'

module Engine
  module Game
    module G1817
      module Round
        class Merger < Engine::Round::Merger
          def self.round_name
            'Merger and Conversion Round'
          end

          def self.short_name
            'MR'
          end

          def select_entities
            @game.merge_corporations.sort
          end

          def setup
            super
            skip_steps
            next_entity! if finished?
          end

          def after_process(action)
            return if action.free?
            return if active_step

            purchase_tokens(@converted) if @tokens_needed
            liquidate!(@converted) if @tokens_needed
            @converted = nil

            @game.players.each(&:unpass!)
            next_entity!
          end

          def purchase_tokens(corporation)
            return @tokens_needed = nil if @tokens_needed.zero?

            cost = token_cost(corporation)
            return if needs_money?(corporation)

            tokens_needed.times { corporation.tokens << Engine::Token.new(corporation, price: 0) }
            if cost.positive?
              corporation.spend(cost, @game.bank)
              @log << "#{corporation.name} pays #{@game.format_currency(cost)}"\
                      " for #{tokens_needed} token#{tokens_needed > 1 ? 's' : ''}"
            else
              @log << "#{corporation.name} acquires #{tokens_needed} token#{tokens_needed > 1 ? 's' : ''}"
            end
            @tokens_needed = nil
          end

          def needs_money?(corporation)
            tokens_needed && token_cost(corporation) > corporation.cash
          end

          def token_cost(corporation)
            cost = (tokens_needed || 0) * 50
            cost -= 50 if corporation.companies.include?(@game.station_subsidy_private)
            cost
          end

          def liquidate!(corporation)
            @game.liquidate!(corporation)
            @log << "#{corporation.name} cannot purchase required tokens and liquidates"
            @tokens_needed = nil
          end

          def next_entity!
            next_entity_index! if @entities.any?
            return if @entity_index.zero?

            @steps.each(&:unpass!)
            @steps.each(&:setup)

            skip_steps
            next_entity! if finished?
          end

          def entities
            if @converted
              @game.players
            else
              @entities
            end
          end
        end
      end
    end
  end
end
