# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module GFrost1831
      module Step
        class FactionDividend < Engine::Step::Base
          def actions(entity)
            return [] unless entity == current_entity
            return [] unless entity.type == :faction
            return [] if @paid_dividend

            # Factions auto-pay (no player action needed) — use 'pass' to trigger
            ['pass']
          end

          def auto_actions(entity)
            return [] unless entity.type == :faction
            return [] if @paid_dividend

            [Engine::Action::Pass.new(entity)]
          end

          def process_pass(action)
            entity = action.entity
            return super unless entity.type == :faction

            pay_faction_dividends(entity)
            @paid_dividend = true
            pass!
          end

          def setup
            @paid_dividend = false
          end

          def description
            'Faction Dividends'
          end

          def log_skip(entity)
            # Only log for factions, not regular corporations
            return unless entity.type == :faction

            super
          end

          private

          def pay_faction_dividends(faction)
            basic_rent = faction_basic_rent
            city_revenue = faction_city_revenue(faction)
            cert_revenue = faction_cert_revenue(faction)
            influence_revenue = faction_influence_revenue(faction)

            total = basic_rent + city_revenue + cert_revenue + influence_revenue

            @log << "#{faction.name} earns £#{basic_rent} (Basic Rent - Phase #{@game.phase.name})"
            @log << "#{faction.name} earns £#{city_revenue} (Bases on Cities)" if city_revenue.positive?
            @log << "#{faction.name} earns £#{influence_revenue} (Influence)"

            return if total.zero?

            per_share = (total.to_f / 5).floor

            paid_to_players = {}
            faction.player_share_holders.each do |player, percent|
              next unless percent.positive?

              amount = (total * percent / 100).floor
              next unless amount.positive?

              @game.bank.spend(amount, player)
              paid_to_players[player] = amount
            end

            # Unsold certificates in IPO don't pay
            payout_str = paid_to_players.map { |p, a| "#{@game.format_currency(a)} to #{p.name}" }.join(', ')
            @log << "#{faction.name} pays out #{@game.format_currency(total)} = "\
                    "#{@game.format_currency(per_share)} per share (#{payout_str})"

            op_info = Object.new
            op_info.define_singleton_method(:revenue) { total }
            op_info.define_singleton_method(:dividend_kind) { 'payout' }
            op_info.define_singleton_method(:dividend) { nil }
            op_info.define_singleton_method(:routes) { {} }
            op_info.define_singleton_method(:nodes) { {} }
            op_info.define_singleton_method(:halts) { {} }
            op_info.define_singleton_method(:laid_hexes) { [] }
            faction.operating_history[[@game.turn, @round.round_num]] = op_info
          end

          def faction_basic_rent
            case @game.phase.name
            when '3', '4' then 20
            when '5', '6' then 30
            when 'D' then 40
            else 0
            end
          end

          def faction_city_revenue(faction)
            total = 0
            phase_color = @game.phase.current[:tiles].last

            faction.tokens.select(&:used).each do |token|
              city = token.city
              next unless city

              rev = city.revenue
              if rev.is_a?(Hash)
                total += rev[phase_color] || rev.values.last || 0
              elsif rev.is_a?(Numeric)
                total += rev
              end
            end
            total
          end

          def faction_cert_revenue(faction)
            (@game.faction_certificates[faction.id]&.size || 0) * 10
          end

          def faction_influence_revenue(faction)
            # £10 per Influence in the faction's Parliament reserve
            @game.faction_influence(faction.id) * 10
          end
        end
      end
    end
  end
end
