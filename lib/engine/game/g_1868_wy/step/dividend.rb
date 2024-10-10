# frozen_string_literal: true

require_relative '../../../step/dividend'
require_relative '../skip_coal_and_oil'

module Engine
  module Game
    module G1868WY
      module Step
        class Dividend < Engine::Step::Dividend
          include G1868WY::SkipCoalAndOil

          def share_price_change(entity, revenue = 0)
            return {} if entity.minor?
            return { share_direction: :left, share_times: 1 } if revenue.zero?

            if (times = [revenue.div(entity.share_price.price), 3].min).positive?
              { share_direction: :right, share_times: times }
            else
              {}
            end
          end

          def log_run_payout(entity, kind, revenue, subsidy, action, payout)
            super unless entity.minor?
          end

          def rust_obsolete_trains!(entity, log: false)
            # reattach big boy token to individual train from before the
            # double-heading
            if entity == @game.big_boy_private.owner && @game.big_boy_train_dh_original
              @game.attach_big_boy(@game.big_boy_train_dh_original, log: false)
            end

            super(entity, log: false)
          end

          def process_dividend(action)
            super
            @game.double_headed_trains = []
          end

          # Teapot Dome: force a float in both JS and Ruby
          def payout_per_share(entity, revenue)
            revenue % 10 == 5 ? revenue / 10.0 : super
          end

          # Teapot Dome: log the fractional amount that will be rounded after
          # multiplying by share count, i.e., in
          # Engine::Step::Dividend#dividends_for_entity()
          def log_payout_shares(entity, revenue, per_share, receivers)
            return super unless revenue % 10 == 5

            @log << "#{entity.name} pays out #{@game.format_currency(revenue)} = "\
                    "$#{revenue / 10.0} per share, rounded up (#{receivers})"
          end

          def dividends_for_entity(entity, holder, per_share)
            if (up = @game.union_pacific) == entity &&
               up == holder &&
               up == @game.up_double_share.owner &&
               @game.ames_bros.owner&.player?
              num_shares = up.num_shares_of(up) - 2
              # Teapot Dome private can cause per_share to be a float
              (num_shares * per_share).ceil
            else
              super
            end
          end
        end
      end
    end
  end
end
