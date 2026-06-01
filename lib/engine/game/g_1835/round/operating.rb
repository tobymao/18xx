# frozen_string_literal: true

require_relative '../../../round/operating'
module Engine
  module Game
    module G1835
      module Round
        class Operating < Engine::Round::Operating
          def setup
            @current_operator = nil
            @home_token_timing = @game.class::HOME_TOKEN_TIMING
            # omit paying out companies if any Prussian conversion could happen. Payout is then handled by MinorExchange
            # after all choices have been made
            @game.payout_companies unless any_conversion_choice_available?
            @game.conversion_choice_during_or = false

            @entities.each { |c| @game.place_home_token(c) } if @home_token_timing == :operating_round
            @entities.each do |entity|
              entity.trains.each { |train| train.operated = false } if entity.operator?
            end
            (@game.corporations + @game.minors + @game.companies).each(&:reset_ability_count_this_or!)
            after_setup
          end

          def pending_tokens
            @pending_tokens ||= []
          end

          def any_conversion_choice_available?
            # Owner of 2 has the choice to form the PR
            return true if @game.pr_can_form && !@game.corporation_by_id('PR').floated?
            # PR has already been formed and not all minors/companies have been converted yet
            if @game.corporation_by_id('PR').floated? && !(@game.minors + @game.prussian_companies).reject(&:closed?).empty?
              return true
            end

            false
          end
        end
      end
    end
  end
end
