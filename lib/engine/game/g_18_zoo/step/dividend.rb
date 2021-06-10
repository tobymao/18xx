# frozen_string_literal: true

require_relative 'choose_ability_on_or'

module Engine
  module Game
    module G18ZOO
      module Step
        class Dividend < Engine::Step::Dividend
          include Engine::Game::G18ZOO::ChooseAbilityOnOr

          def dividend_options(entity)
            revenue = @game.routes_revenue(routes)[:value]
            subsidy = @game.routes_subsidy(routes)

            dividend_types.map do |type|
              [type, send(type, entity, revenue, subsidy)]
            end.to_h
          end

          def share_price_change(entity, revenue)
            :right if revenue >= @game.threshold(entity)
          end

          def withhold(_entity, revenue, subsidy)
            {
              corporation: (revenue / 25.0).ceil + subsidy,
              per_share: 0,
              share_direction: :left,
              share_times: 1,
              divs_to_corporation: 0,
            }
          end

          def payout(entity, revenue, subsidy)
            {
              corporation: subsidy,
              per_share: payout_per_share(entity, revenue),
              share_direction: revenue >= @game.threshold(entity) ? :right : nil,
              share_times: 1,
              divs_to_corporation: 0,
            }
          end

          def dividends_for_entity(entity, holder, per_share)
            holder.player? ? super : 0
          end

          def payout_per_share(entity, revenue)
            real_revenue = revenue.is_a?(Hash) ? revenue[:value] : revenue
            @game.bonus_payout_for_share(@game.share_price_updated(entity, real_revenue))
          end

          def payout_shares(entity, revenue)
            revenue_hash = { type: :revenue, value: revenue + @subsidy }
            per_share = payout_per_share(entity, revenue_hash)

            payouts = {}
            (@game.players + @game.corporations).each do |payee|
              payout_entity(entity, payee, per_share, payouts)
            end

            receivers = payouts
                          .sort_by { |_r, c| -c }
                          .map { |receiver, cash| "#{@game.format_currency(cash)} to #{receiver.name}" }.join(', ')

            @log << "#{entity.name} collects #{@game.format_currency(revenue_hash)}. "\
                      "#{entity.name} pays #{@game.format_currency(per_share)} per share (#{receivers})"

            bonus = @game.bonus_payout_for_president(@game.share_price_updated(entity, revenue))
            return unless bonus.positive?

            @game.bank.spend(bonus, entity.player, check_positive: false)
            @log << "President #{entity.player.name} earns #{@game.format_currency(bonus)}"\
              " as a bonus from #{entity.name} run"
          end

          def process_dividend(action)
            @subsidy = @game.routes_subsidy(routes)

            entity = action.entity
            revenue_hash = @game.routes_revenue(routes)
            revenue = revenue_hash[:value]
            kind = action.kind.to_sym
            payout = dividend_options(entity)[kind]

            rust_obsolete_trains!(entity)

            entity.operating_history[[@game.turn, @round.round_num]] = OperatingInfo.new(
              routes,
              action,
              revenue_hash,
              @round.laid_hexes
            )

            entity.trains.each { |train| train.operated = true }

            @round.routes = []

            log_run_payout(entity, kind, revenue, action, payout)

            payout_corporation(payout[:corporation], entity)

            payout_shares(entity, revenue - payout[:corporation]) if payout[:per_share].positive?

            change_share_price(entity, payout)

            pass!

            @subsidy = 0

            action.entity.remove_assignment!('BARREL') if @game.two_barrels_used_this_or?(action.entity)
          end
        end
      end
    end
  end
end
