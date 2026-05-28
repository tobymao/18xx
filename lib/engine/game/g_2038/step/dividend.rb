# frozen_string_literal: true

require_relative '../../../step/dividend'

module Engine
  module Game
    module G2038
      module Step
        class Dividend < Engine::Step::Dividend
          # Corporations choose: full payout (stock +2), half payout (stock +1),
          # or withhold (stock -1).
          CORP_DIVIDEND_TYPES = %i[payout half withhold].freeze

          # Independents (minors) choose: split half with owner, or retain all
          # in treasury. No stock price — minors have no share price.
          MINOR_DIVIDEND_TYPES = %i[split retain].freeze

          def dividend_types
            current_entity.minor? ? self.class::MINOR_DIVIDEND_TYPES : self.class::CORP_DIVIDEND_TYPES
          end

          def skip!
            default_kind = current_entity.minor? ? 'retain' : 'withhold'
            action = Engine::Action::Dividend.new(current_entity, kind: default_kind)
            action.id = @game.actions.last.id if @game.actions.last
            process_dividend(action)
          end

          def round_state
            super.merge(laid_hexes: [])
          end

          # ---------------------------------------------------------------------------
          # Corporation dividend methods
          # ---------------------------------------------------------------------------

          # Full payout: all revenue to shareholders. Stock moves right 2.
          # (share_price_change handles the +2; this just sets per_share.)
          def payout(entity, revenue)
            { corporation: 0, per_share: payout_per_share(entity, revenue) }
          end

          # Half payout: half to shareholders, half retained. Stock moves right 1.
          def half(entity, revenue)
            corp = revenue / 2
            { corporation: corp, per_share: payout_per_share(entity, revenue - corp) }
          end

          # Withhold: all retained. Stock moves left 1.
          def withhold(_entity, revenue)
            { corporation: revenue, per_share: 0 }
          end

          # ---------------------------------------------------------------------------
          # Minor dividend methods
          # ---------------------------------------------------------------------------

          # Split: owner gets half, treasury retains half. No price movement.
          def split(entity, revenue)
            player_share = revenue / 2
            { corporation: revenue - player_share, per_share: payout_per_share(entity, player_share) }
          end

          # Retain: all stays in treasury. No price movement.
          def retain(_entity, revenue)
            { corporation: revenue, per_share: 0 }
          end

          # ---------------------------------------------------------------------------
          # Stock price movement
          # ---------------------------------------------------------------------------

          # shareholders_revenue is the portion going to shareholders (revenue - corporation).
          #   Full payout  → shareholders_revenue == total_revenue → right 2
          #   Half payout  → 0 < shareholders_revenue < total_revenue → right 1
          #   Withhold     → shareholders_revenue == 0 → left 1
          #   Minor        → no stock price → no movement
          def share_price_change(entity, shareholders_revenue)
            return {} if entity.minor?
            return { share_direction: :left,  share_times: 1 } if shareholders_revenue.zero?
            return { share_direction: :right, share_times: 2 } if shareholders_revenue == total_revenue

            { share_direction: :right, share_times: 1 }
          end

          # ---------------------------------------------------------------------------
          # Logging
          # ---------------------------------------------------------------------------

          def log_run_payout(entity, kind, revenue, subsidy, _action, payout)
            if entity.minor?
              case kind
              when :split
                player_amount = payout[:per_share]  # minor has 1 share; per_share == owner's cut
                corp_amount   = payout[:corporation]
                @log << "#{entity.name} splits #{@game.format_currency(revenue)}: "\
                        "#{@game.format_currency(player_amount)} to owner, "\
                        "#{@game.format_currency(corp_amount)} to treasury"
              when :retain
                @log << "#{entity.name} retains #{@game.format_currency(revenue)} in treasury"
              end
            else
              case kind
              when :payout
                @log << "#{entity.name} pays full dividend of #{@game.format_currency(revenue)}"
              when :half
                corp = payout[:corporation]
                paid = revenue - corp
                @log << "#{entity.name} pays half dividend — "\
                        "#{@game.format_currency(paid)} to shareholders, "\
                        "#{@game.format_currency(corp)} retained"
              when :withhold
                @log << "#{entity.name} withholds #{@game.format_currency(revenue)}"
              end
            end

            return unless subsidy.positive?

            @log << "#{entity.name} earns #{@game.subsidy_name} of #{@game.format_currency(subsidy)}"
          end
        end
      end
    end
  end
end
