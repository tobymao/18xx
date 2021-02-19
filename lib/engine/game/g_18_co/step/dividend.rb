# frozen_string_literal: true

require_relative '../../../step/dividend'

module Engine
  module Game
    module G18CO
      module Step
        class Dividend < Engine::Step::Dividend
          def share_price_change(entity, revenue = 0)
            return { share_direction: :left, share_times: 1 } unless revenue.positive?

            return { share_direction: :right, share_times: 1 } unless revenue >= entity.share_price.price * 2

            { share_direction: %i[right up], share_times: [1, 1] }
          end

          def process_dividend(action)
            super

            entity = action.entity
            return unless entity.operating_history[[@game.turn, @round.round_num]].revenue.positive?

            close_companies_on_run_train!(entity)
            return unless (mine_revenue = @game.mines_total(entity)).positive?

            @game.bank.spend(mine_revenue, entity)
            @log << "#{entity.name} collects #{@game.format_currency(mine_revenue)} from mines"
          end

          def close_companies_on_run_train!(entity)
            @game.companies.each do |company|
              next if company.closed?

              @game.abilities(company, :close, time: 'run_train') do |ability|
                next if entity&.name != ability.corporation

                company.close!
                @log << "#{company.name} closes"
              end
            end
          end
        end
      end
    end
  end
end
