# frozen_string_literal: true

require_relative '../../../step/dividend'

module Engine
  module Game
    module G1835
      module Step
        class Dividend < Engine::Step::Dividend
          def actions(entity)
            return [] if entity.minor?

            super
          end

          def skip!
            entity = current_entity
            return process_minor_income(entity) if entity&.minor?

            super
          end

          def dividends_for_entity(entity, holder, per_share)
            num_shares = num_paying_shares(entity, holder)
            (num_shares * per_share).floor
          end

          # In 1835, only bank pool (market) shares pay the corporation treasury.
          # Unsold IPO shares pay nobody.
          def corporation_dividends(entity, per_share)
            return 0 if entity.minor?

            dividends_for_entity(entity, @game.share_pool, per_share)
          end

          def round_state
            super.merge(
              {
                non_paying_shares: Hash.new { |h, k| h[k] = Hash.new(0) },
              }
            )
          end

          private

          def num_paying_shares(entity, holder)
            # Use ceil: false so fractional shares (e.g. PR's 5% shares) are not
            # rounded up to a full unit, which would cause overpayment.
            # non_paying_shares is stored in the same fractional units (see merge_entity_to_prussian!).
            holder.num_shares_of(entity, ceil: false) - @round.non_paying_shares[holder][entity]
          end

          def process_minor_income(entity)
            revenue = total_revenue

            entity.operating_history[[@game.turn, @round.round_num]] = OperatingInfo.new(
              routes,
              Engine::Action::Dividend.new(entity, kind: 'payout'),
              revenue,
              @round.laid_hexes
            )

            @game.close_companies_on_event!(entity, 'ran_train') unless @round.routes.empty?
            entity.trains.each { |train| train.operated = true }
            rust_obsolete_trains!(entity)

            @round.routes = []
            @round.extra_revenue = 0

            if revenue.positive?
              owner_share = (revenue / 2.0).floor
              treasury_share = revenue - owner_share
              @game.bank.spend(owner_share, entity.owner)
              @game.bank.spend(treasury_share, entity)
              @log << "#{entity.name} earns #{@game.format_currency(revenue)}: " \
                      "#{@game.format_currency(owner_share)} to #{entity.owner.name}, " \
                      "#{@game.format_currency(treasury_share)} to treasury"
            else
              @log << "#{entity.name} does not run"
            end

            pass!
          end
        end
      end
    end
  end
end
