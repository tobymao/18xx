# frozen_string_literal: true

require_relative 'choose_ability_on_or'

module Engine
  module Game
    module G18ZOO
      module Step
        class Dividend < Engine::Step::Dividend
          include Engine::Game::G18ZOO::ChooseAbilityOnOr

          def dividend_options(entity)
            revenue = @game.routes_revenue(routes)
            subsidy = @game.routes_subsidy(routes)

            dividend_types.to_h do |type|
              [type, send(type, entity, revenue, subsidy)]
            end
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
            @game.bonus_payout_for_share(@game.share_price_updated(entity, revenue))
          end

          def payout_shares(entity, revenue)
            super(entity, revenue + @subsidy)

            bonus = @game.bonus_payout_for_president(@game.share_price_updated(entity, revenue))
            return unless bonus.positive?

            @game.bank.spend(bonus, entity.player, check_positive: false)
            @log << "President #{entity.player.name} earns #{@game.format_currency(bonus)}"\
                    " as a bonus from #{entity.name} run"
          end

          def process_dividend(action)
            @subsidy = @game.routes_subsidy(routes)

            super

            @subsidy = 0

            action.entity.remove_assignment!('BARREL') if @game.two_barrels_used_this_or?(action.entity)
          end

          def rust_obsolete_trains!(entity)
            rusted_trains = []
            entity.trains.select(&:obsolete).each do |train|
              train.rusts_on = '2S'
              # do not rust if 1S run instead of train
              next if @round.train_in_route.include?('1S-0') && !@round.train_in_route.include?(train.id)
              next unless @game.rust?(train, nil)

              rusted_trains << train.name
              @game.rust(train)
            end

            @log << "-- Event: Obsolete trains rust (#{rusted_trains.join(', ')}) --" if rusted_trains.any?
          end

          private

          def log_payout_shares(entity, revenue, per_share, receivers)
            @log << "#{entity.name} collects #{@game.format_revenue_currency(revenue)}. "\
                    "#{entity.name} pays #{@game.format_currency(per_share)} per share (#{receivers})"
          end
        end
      end
    end
  end
end
