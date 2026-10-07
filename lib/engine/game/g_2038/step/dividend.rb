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
            current_entity.minor? ? MINOR_DIVIDEND_TYPES : CORP_DIVIDEND_TYPES
          end

          def skip!
            default_kind = current_entity.minor? ? 'retain' : 'withhold'
            action = Engine::Action::Dividend.new(current_entity, kind: default_kind)
            action.id = @game.actions.last.id if @game.actions.last
            process_dividend(action)
          end

          # The base engine's payout_shares/dividends_for_entity re-derive
          # per_share from a revenue figure and ceil it *per holder*, which
          # for a fractional rate (e.g. $9.50) gives a 1-share holder $10
          # (ceil of 9.50) but a 2-share holder $19 (exact, no rounding
          # needed) -- two different effective per-share rates out of the
          # same dividend. Per the user's rule -- "for partial payouts you
          # round down for the company and up for the players" -- the rate
          # itself must be a single whole dollar figure shared by every
          # holder, not a per-holder ceil of a fractional rate. half below
          # computes that uniform rate once and how much it actually costs
          # to pay every real holder (shareholder_payout_total, since bank-
          # held IPO shares and open-market shares -- not in
          # players/corporations -- never get paid regardless of
          # capitalization type); the corporation absorbs whatever's left
          # of revenue. process_dividend and payout_shares are overridden
          # only so that already-final per_share flows straight through to
          # disbursement instead of being silently re-derived from a
          # revenue/total_shares division that would undo this fix for any
          # kind other than half; both otherwise behave identically to the
          # base version.
          def process_dividend(action)
            entity = action.entity
            revenue = total_revenue
            subsidy = total_subsidy
            kind = action.kind.to_sym
            payout = dividend_options(entity)[kind]

            entity.operating_history[[@game.turn, @round.round_num]] =
              OperatingInfo.new(routes, action, revenue, @round.laid_hexes)

            @game.close_companies_on_event!(entity, 'ran_ship') unless @round.routes.empty?
            entity.trains.each { |ship| ship.operated = true }
            rust_obsolete_trains!(entity)
            @round.routes = []
            @round.extra_revenue = 0

            log_run_payout(entity, kind, revenue, subsidy, action, payout)

            payout_corporation(payout[:corporation] + subsidy, entity)
            payout_shares(entity, payout[:per_share]) if payout[:per_share].positive?

            change_share_price(entity, payout)
            pass!
          end

          # Same per_share, per-holder dividends_for_entity ceil logic as
          # the base engine's own payout_shares -- the difference is that
          # per_share here is already final (computed by half/payout/split
          # above) rather than re-derived from a revenue argument, so it
          # can't drift from what shareholder_payout_total (below) already
          # assumed.
          # A minor never registers a Share for its own owner -- Minor
          # includes Ownable (a plain owner attr), not the ShareHolder
          # machinery a Corporation's IPO/president's-cert setup relies
          # on -- so owner.percent_of(minor) is always 0 and the generic
          # share-based path below (dividends_for_entity, ultimately
          # num_shares_of) silently finds nothing to pay every single
          # time, even though per_share here IS the owner's whole payout
          # (a minor's total_shares is 1). Pay the owner directly instead
          # of routing through the share-holder lookup that can never find them.
          def payout_shares(entity, per_share)
            if entity.minor?
              owner = entity.owner
              return unless owner

              @game.bank.spend(per_share, owner, check_positive: false)
              log_payout_shares(entity, per_share, per_share, "#{@game.format_currency(per_share)} to #{owner.name}")
              return
            end

            payouts = {}
            (@game.players + @game.corporations).each { |payee| payout_entity(entity, payee, per_share, payouts) }

            receivers = payouts
                          .sort_by { |_r, c| -c }
                          .map { |receiver, cash| "#{@game.format_currency(cash)} to #{receiver.name}" }.join(', ')

            log_payout_shares(entity, payouts.values.sum, per_share, receivers)
          end

          # What payout_shares above is about to actually disburse for a
          # given whole-dollar per_share (same dividends_for_entity ceil-
          # per-holder logic) without paying anyone yet -- used only to
          # figure out how much the corporation should be left holding.
          def shareholder_payout_total(entity, per_share)
            (@game.players + @game.corporations).sum { |payee| dividends_for_entity(entity, payee, per_share) }
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
          #
          # Per the user: "for partial payouts you round down for the
          # company and up for the players." per_share is ceiled once,
          # globally, to a whole dollar (a $150 half-pay on 10 shares gives
          # $8/share -- ceil of $7.50 -- confirmed with the user; a $190
          # half-pay gives $10/share -- ceil of $9.50 -- also confirmed).
          # The corporation gets whatever's left of revenue after actually
          # paying every real holder that rate (shareholder_payout_total --
          # bank-held IPO shares and open-market shares never get paid
          # regardless of capitalization type, so this can be less than
          # per_share * total_shares).
          def half(entity, revenue)
            per_share = (revenue / 2.0 / entity.total_shares).ceil
            paid = shareholder_payout_total(entity, per_share)
            { corporation: revenue - paid, per_share: per_share }
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
