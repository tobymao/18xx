# frozen_string_literal: true

module Engine
  module Game
    module G1868WY
      module CreditMobilier
        attr_accessor :cm_westernmost, :cm_connected, :cm_pending, :cm_unchecked

        OMAHA_COLUMN = 27

        CREDIT_MOBILIER_HEXES = %w[
          J2 J4 J6 J8 J10 J12 J14 J16 J18 J20 J22
          K3 K5 K7 K9 K11 K13 K15 K17 K19 K21 K23
          L2 L4 L6 L8 L10 L12 L14 L16 L20 L22
          M3 M5 M7 M9 M11 M13 M17 M21 M23 M25
        ].to_h { |h| [h, true] }.freeze

        def setup_credit_mobilier
          @cm_westernmost = OMAHA_COLUMN
          @cm_cumulative = Hash.new(0)
          setup_credit_mobilier_for_round
        end

        def setup_credit_mobilier_for_round
          @cm_connected = {}
          @cm_unchecked = {}
          @cm_pending = {}
        end

        def credit_mobilier_check_tile_lay_action(action)
          return if @phase.name.to_i >= 5 || @golden_spike_complete

          hex = action.hex

          return unless CREDIT_MOBILIER_HEXES.include?(hex.coordinates)
          return unless hex.column < @cm_westernmost
          return unless credit_mobilier_valid_tile?(hex.tile)
          return unless (amount = credit_mobilier_payout_amount(hex)).positive?

          @cm_pending[hex] = amount
        end

        def credit_mobilier_valid_tile?(tile)
          tile.color == :yellow ||
            (tile.color == :green && tile.label.to_s == '$20')
        end

        def omaha
          @omaha ||= hex_by_id('M27').tile.offboards.first
        end

        def omaha_connection?(hex)
          omaha.walk do |path, _vp, _visited|
            return true if path.hex == hex
          end
          false
        end

        def credit_mobilier_payout_amount(hex)
          terrain_total =
            case hex.tile.color
            when :yellow
              hex.original_tile.upgrades.sum(&:cost)
            when :green
              20
            end

          terrain_total += 30 if @border_before && !@border_after

          terrain_total
        end

        def credit_mobilier_payout!(hex)
          payout = credit_mobilier_payout_amount(hex)
          return unless payout.positive?

          per_share = payout / 10
          @cm_cumulative[:total] += payout

          payouts = {}

          payout = union_pacific.num_treasury_shares * per_share
          payouts[union_pacific] = payout
          @bank.spend(payout, union_pacific) if payout.positive?
          @cm_cumulative[union_pacific.id] += payout

          union_pacific.player_share_holders.each do |player, share_percentage|
            payout = (share_percentage / 10) * per_share
            payouts[player] = payout
            @bank.spend(payout, player) if payout.positive?

            @cm_cumulative[player.name] += payout
          end

          receivers = payouts
                        .sort_by { |_r, c| -c }
                        .map { |receiver, cash| "#{format_currency(cash)} to #{receiver.name}" }.join(', ')

          @log << "Crédit Mobilier pays out to UP shareholders for building on #{hex.name}: "\
                  "#{format_currency(per_share * 10)} = #{format_currency(per_share)} per share (#{receivers})"
          log_cumulative
          # @log << "Crédit Mobilier pending: #{@cm_pending}"
        end

        def log_cumulative
          @log << "Crédit Mobilier cumulative pay outs: #{@cm_cumulative.sort_by { |_, v| -v }.to_h.to_json}"
        end
      end
    end
  end
end
