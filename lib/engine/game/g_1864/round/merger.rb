# frozen_string_literal: true

require_relative '../../g_1867/round/merger'

module Engine
  module Game
    module G1864
      module Round
        class Merger < G1867::Round::Merger
          def select_entities
            @regionalizing = !@game.pending_up_share_buyers.empty?
            @regionalizing ? [] : super
          end

          def setup
            super
            start_merging! if regionalized?
          end

          def after_process(action)
            return start_merging! if regionalized?

            super
          end

          private

          def regionalized?
            @regionalizing && @game.pending_up_share_buyers.empty?
          end

          def start_merging!
            @entities = select_entities
            @steps.each(&:unpass!)
            @steps.each(&:setup)
            clear_cache!
            setup
          end
        end
      end
    end
  end
end
