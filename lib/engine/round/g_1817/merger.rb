# frozen_string_literal: true

require_relative '../merger'

module Engine
  module Round
    module G1817
      class Merger < Merger
        def name
          'Merger and Conversion Round'
        end

        def select_entities
          @game
            .corporations
            .select { |c| c.floated? && c.share_price.normal_movement? && !c.share_price.acquisition? }
            .sort
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
          return unless token_cost.positive?
          return if needs_money?(corporation)

          corporation.spend(token_cost, @game.bank)
          tokens_needed.times { corporation.tokens << Engine::Token.new(corporation, price: 0) }
          @log << "#{corporation.name} pays #{@game.format_currency(token_cost)}"\
            " for #{tokens_needed} token#{tokens_needed > 1 ? 's' : ''}"
          @tokens_needed = nil
        end

        def needs_money?(corporation)
          tokens_needed && token_cost > corporation.cash
        end

        def token_cost
          (tokens_needed || 0) * 50
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
