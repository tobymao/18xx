# frozen_string_literal: true

require_relative '../../../step/dividend'
require_relative '../../../step/half_pay'

module Engine
  module Game
    module G18OE
      module Step
        class Dividend < Engine::Step::Dividend
          include Engine::Step::HalfPay

          def actions(entity)
            return [] if %i[minor national].include?(entity.type) || @game.repeat_last_revenue?(entity)

            super
          end

          def total_revenue
            return @game.last_revenue_info(current_entity).revenue if current_entity && @game.repeat_last_revenue?(current_entity)
            return national_revenue.total if current_entity && @game.national?(current_entity)

            super
          end

          def skip!
            if @game.repeat_last_revenue?(current_entity)
              kind = @game.last_revenue_info(current_entity).dividend_kind
              @log << "#{current_entity.name} repeats its revenue from OR #{@game.turn}.#{@round.round_num - 1}"
              return process_dividend(Action::Dividend.new(current_entity, kind: kind))
            end

            case current_entity.type
            when :minor
              kind = total_revenue.zero? ? 'withhold' : 'half'
            when :national
              log_national_revenue
              kind = total_revenue.zero? ? 'withhold' : 'payout'
            else
              return super
            end
            process_dividend(Action::Dividend.new(current_entity, kind: kind))
          end

          def half_pay_withhold_amount(_entity, revenue)
            (revenue / 2).floor
          end

          def share_price_change(entity, revenue)
            return {} if %i[minor regional].include?(entity.type)
            return { share_direction: :left, share_times: 1 } if revenue.zero?
            return {} if revenue < entity.share_price.price

            { share_direction: :right, share_times: 1 }
          end

          def dividend_types
            case current_entity.type
            when :minor
              %i[half withhold]
            when :national
              %i[payout withhold]
            else
              %i[withhold half payout]
            end
          end

          private

          def log_national_revenue
            revenue = national_revenue
            capacity = "capacity #{revenue.city_capacity} cities, #{revenue.doubled_capacity} doubled, "\
                       "#{revenue.town_capacity} towns"
            cities = "cities #{@game.format_currency(revenue.city_revenue)} (#{revenue.linked_city_values.size} linked, "\
                     "#{revenue.unlinked_city_count} unlinked, #{revenue.filler_city_count} at "\
                     "#{@game.format_currency(@game.national_filler_city_revenue)})"
            towns = "towns #{@game.format_currency(revenue.town_revenue)} (#{revenue.linked_town_values.size} linked, "\
                    "#{revenue.unlinked_town_count} unlinked, #{revenue.filler_town_count} at "\
                    "#{@game.format_currency(@game.national_filler_town_revenue)})"
            pullman = "Pullman #{@game.format_currency(revenue.pullman_revenue)}"
            @log << "#{current_entity.name} runs as a national (#{capacity}): #{cities}, #{towns}, #{pullman}"
          end

          def national_revenue
            @national_revenue = nil unless @national_revenue_entity == current_entity
            @national_revenue_entity = current_entity
            @national_revenue ||= @game.national_revenue(current_entity)
          end
        end
      end
    end
  end
end
