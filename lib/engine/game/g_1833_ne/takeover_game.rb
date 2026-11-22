# frozen_string_literal: true

require_relative '../base'

module Engine
  module Game
    module G1833NE
      module TakeoverGame
        VARIABLE_START = :variable_start
        TAKEOVER_STATUS = 'takeovers'
        TAKEOVERS_FROM_PHASE = 'II'
        TAKEOVER_TRAIN_PHASE = 'IV'
        UNTRACKED_HOME_COST = 80
        TRACKED_HOME_COST = 120
        TRACKED_HOME_MIN_PRICE = 60
        TAKEOVER_TRAIN_LIMITS = { 'I' => 3, 'II' => 3, 'III' => 2, 'IV' => 1, 'V' => 1 }.freeze

        STATUS_TEXT = Base::STATUS_TEXT.merge(
          TAKEOVER_STATUS => [
            'Takeovers',
            'Variable Start railroads may be launched, and corporations may take over other corporations',
          ],
        ).freeze

        def variable_start_type
          self.class::VARIABLE_START
        end

        def takeover_status
          self.class::TAKEOVER_STATUS
        end

        def takeovers_from_phase
          self.class::TAKEOVERS_FROM_PHASE
        end

        def takeover_train_phase
          self.class::TAKEOVER_TRAIN_PHASE
        end

        def untracked_home_cost
          self.class::UNTRACKED_HOME_COST
        end

        def tracked_home_cost
          self.class::TRACKED_HOME_COST
        end

        def tracked_home_min_price
          self.class::TRACKED_HOME_MIN_PRICE
        end

        def takeover_train_limits
          self.class::TAKEOVER_TRAIN_LIMITS
        end

        def setup_takeover_game
          @takeovers_by = Hash.new(0)
          @blocking_corporation = Corporation.new(sym: 'B', name: 'Blocking', logo: '1833_ne/blocking', tokens: [0])
        end

        def takeover_game?
          @takeover_game ||= @optional_rules&.include?(:takeover_game)
        end

        def takeovers_allowed?
          @phase.status.include?(takeover_status)
        end

        def num_trains(train)
          return takeover_game? ? 5 : 3 if train[:name] == takeover_train_name

          train[:num]
        end

        def game_corporations
          return self.class::CORPORATIONS if takeover_game?

          self.class::CORPORATIONS.reject { |corporation| corporation[:type].to_sym == variable_start_type }
        end

        def game_phases
          return self.class::PHASES unless takeover_game?

          takeovers_from = self.class::PHASES.index { |phase| phase[:name] == takeovers_from_phase }
          self.class::PHASES.map.with_index do |phase, index|
            status = Array(phase[:status])
            status += [takeover_status] if index >= takeovers_from
            phase.merge(train_limit: takeover_train_limits.fetch(phase[:name]), status: status)
          end
        end

        def train_limit(entity)
          super + @takeovers_by[entity]
        end

        def takeover_round
          G1833NE::Round::Takeover.new(self, [
            Engine::Step::DiscardTrain,
            G1833NE::Step::RedeemTakeoverShares,
            G1833NE::Step::TakeoverConsent,
            G1833NE::Step::TakeoverCorporation,
          ])
        end

        def new_takeover_round
          @log << '-- Takeover Round -- '
          takeover_round
        end

        def variable_start?(corporation)
          corporation.type == variable_start_type
        end

        def can_par?(corporation, parrer)
          return false if variable_start?(corporation) && !takeovers_allowed?

          super
        end

        def status_array(corporation)
          return unless variable_start?(corporation)

          status = [['Variable Start Corp', 'bold']]
          status << ["Phase available: #{takeovers_from_phase}"] unless takeovers_allowed?
          status
        end

        def home_token_locations(corporation)
          hexes.select { |hex| hex.tile.cities.any? { |city| variable_start_home?(corporation, city) } }
        end

        def variable_start_home?(corporation, city)
          city.hex.id != sherbrooke_hex &&
            city.tokenable?(corporation, free: true) &&
            !home_of_available_corporation?(city) &&
            (untracked_hex?(city.hex) || corporation.par_price.price >= tracked_home_min_price)
        end

        def home_of_available_corporation?(city)
          @corporations.any? do |corporation|
            !corporation.ipoed && corporation.coordinates == city.hex.id && (corporation.city || 0) == city.index
          end
        end

        def untracked_hex?(hex)
          hex.tile.color == :gray || hex.tile.paths.empty?
        end

        def variable_start_home_cost(hex)
          untracked_hex?(hex) ? untracked_home_cost : tracked_home_cost
        end

        def vulnerable?(corporation)
          corporation.trains.all?(&:obsolete)
        end

        def can_attempt_takeover?(corporation)
          corporation.floated? && !corporation.receivership? && !vulnerable?(corporation)
        end

        def takeover_candidates(acquirer)
          return [] if !takeovers_allowed? || !can_attempt_takeover?(acquirer)

          targets = @corporations.select do |target|
            target != acquirer && target.floated? && can_redeem_takeover_shares?(acquirer, target)
          end
          return [] if targets.empty?

          nodes = graph.connected_nodes(acquirer)
          targets.select { |target| target.placed_tokens.any? { |token| nodes[token.city] } }
        end

        def takeover_holdings(target)
          (@players + [@share_pool]).filter_map do |holder|
            shares = holder.num_shares_of(target)
            [holder, shares] if shares.positive?
          end
        end

        def takeover_unissued_shares(acquirer)
          acquirer.shares_of(acquirer).reject(&:president)
        end

        def takeover_swap_capacity(acquirer, holder)
          limit = holder == @share_pool ? market_share_limit(acquirer) : acquirer.max_ownership_percent
          [((limit - holder.percent_of(acquirer)).to_f / acquirer.share_percent).floor, 0].max
        end

        def takeover_swap_caps(acquirer, target)
          takeover_holdings(target).map { |holder, shares| [shares, takeover_swap_capacity(acquirer, holder)].min }
        end

        def takeover_swaps_needed(acquirer, target)
          price = target.share_price.price
          shortfall = (takeover_holdings(target).sum(&:last) * price) - acquirer.cash
          return 0 unless shortfall.positive?

          (shortfall.to_f / price).ceil
        end

        def can_redeem_takeover_shares?(acquirer, target)
          available = [takeover_swap_caps(acquirer, target).sum, takeover_unissued_shares(acquirer).size].min
          takeover_swaps_needed(acquirer, target) <= available
        end

        def takeover_swap_range(acquirer, target, index, swapped)
          caps = takeover_swap_caps(acquirer, target)
          later = caps[(index + 1)..].sum
          min = [takeover_swaps_needed(acquirer, target) - swapped - later, 0].max
          max = [caps[index], takeover_unissued_shares(acquirer).size - swapped].min
          (min..max)
        end

        def takeover_consenter(acquirer, target)
          return if vulnerable?(target)

          president = target.owner
          president if president&.player? && president != acquirer.owner
        end

        def take_over!(acquirer, target, swaps)
          @log << "-- #{acquirer.name} takes over #{target.name} --"
          redeem_takeover_shares!(acquirer, target, swaps)
          adjust_takeover_share_price!(acquirer, target)
          transfer_takeover_tokens!(acquirer, target)
          @takeovers_by[acquirer] += 1
          transfer_takeover_assets!(acquirer, target)
          remove_takeover_train! if @takeovers_by.values.sum.odd?
          close_corporation(target)
          @log << "#{acquirer.name}'s train limit is now #{train_limit(acquirer)}"
          @log << "The certificate limit is now #{cert_limit}"
        end

        def redeem_takeover_shares!(acquirer, target, swaps)
          price = target.share_price.price
          unissued = takeover_unissued_shares(acquirer)
          takeover_holdings(target).each_with_index do |(holder, shares), index|
            swapped = swaps[index]
            unless swapped.zero?
              @share_pool.transfer_shares(ShareBundle.new(unissued.shift(swapped)), holder, allow_president_change: false)
            end
            cash = (shares - swapped) * price
            acquirer.spend(cash, holder == @share_pool ? @bank : holder) if cash.positive?
            @log << "#{acquirer.name} redeems #{holder.name}'s #{shares} #{target.name} share(s) "\
                    "for #{swapped} #{acquirer.name} share(s) and #{format_currency(cash)}"
          end
          update_takeover_presidency!(acquirer)
        end

        def update_takeover_presidency!(corporation)
          previous = corporation.owner
          holdings = @share_pool.presidency_check_shares(corporation)
          max = holdings.values.max
          return if holdings[previous] == max

          president = holdings.select { |_, percent| percent == max }.keys
                        .min_by { |player| @share_pool.distance(previous, player) }
          @share_pool.change_president(corporation.presidents_share, previous, president, previous)
          corporation.owner = president
          @log << "#{president.name} becomes the president of #{corporation.name}"
        end

        def adjust_takeover_share_price!(acquirer, target)
          target_price = target.share_price.price
          acquirer_price = acquirer.share_price.price
          return if target_price == acquirer_price

          old_price = acquirer.share_price
          if target_price < acquirer_price
            @stock_market.move_left(acquirer)
          else
            @stock_market.move_right(acquirer)
          end
          log_share_price(acquirer, old_price)
        end

        def transfer_takeover_tokens!(acquirer, target)
          target.placed_tokens.each do |token|
            city = token.city
            if city.tokened_by?(acquirer)
              token.remove!
              @log << "#{target.name}'s token in #{city.hex.name} is discarded"
              place_blocking_token(city.hex, city: city) if city.hex.id == sherbrooke_hex
            else
              replacement = Engine::Token.new(acquirer)
              acquirer.tokens << replacement
              token.swap!(replacement, check_tokenable: false)
              @log << "#{acquirer.name} replaces #{target.name}'s token in #{city.hex.name}"
            end
          end
          transfer_takeover_reservations!(acquirer, target)
          graph.clear
        end

        def place_blocking_token(hex, city: nil)
          @log << "Placing a blocking token on #{hex.name} (#{hex.location_name})"
          token = Token.new(@blocking_corporation)
          city ||= hex.tile.cities[0]
          city.place_token(@blocking_corporation, token, check_tokenable: false)
        end

        def transfer_takeover_reservations!(acquirer, target)
          hexes.each do |hex|
            hex.tile.cities.each do |city|
              next unless (index = city.reservations.index(target))

              held = city.tokened_by?(acquirer) || city.reserved_by?(acquirer)
              city.reservations[index] = held ? nil : acquirer
            end
            next unless hex.tile.reservations.delete(target)

            hex.tile.reservations << acquirer unless hex.tile.reserved_by?(acquirer)
          end
        end

        def transfer_takeover_assets!(acquirer, target)
          if target.cash.positive?
            @log << "#{acquirer.name} receives #{format_currency(target.cash)} from #{target.name}'s treasury"
            target.spend(target.cash, acquirer)
          end
          %i[trains companies].each do |assets|
            transferred = transfer(assets, target, acquirer)
            next if transferred.empty?

            @log << "#{acquirer.name} receives #{target.name}'s #{assets}: #{transferred.map(&:name).join(', ')}"
          end
        end

        def takeover_train_name
          @takeover_train_name ||= self.class::PHASES.find { |phase| phase[:name] == takeover_train_phase }[:on]
        end

        def remove_takeover_train!
          return unless (train = @depot.upcoming.find { |t| t.sym == takeover_train_name })

          @depot.remove_train(train)
          @log << "An unsold #{train.name} train is removed from the game"
        end
      end
    end
  end
end
