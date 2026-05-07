# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'
require_relative '../../../action/convert'

module Engine
  module Game
    module G18OE
      module Step
        class BuySellParShares < Engine::Step::BuySellParShares
          def setup
            super

            @converting = nil
            @converted = nil
            @trigger_is_president = nil
            @sold = false
          end

          def actions(entity)
            return corporation_actions(entity) if entity.corporation?
            return [] unless entity == current_entity
            return ['sell_shares'] if must_sell?(entity)
            return converting_actions(entity) if @converting
            return converted_actions(entity) if @converted

            actions = []
            actions << 'buy_shares' if can_buy_any?(entity)
            actions << 'par' if can_ipo_any?(entity) || can_float_minor?(entity)
            actions << 'buy_company' if !purchasable_companies(entity).empty? || !buyable_bank_owned_companies(entity).empty?
            actions << 'sell_shares' if can_sell_any?(entity)
            actions << 'convert' if can_convert_any?(entity)
            actions << 'pass' if !can_float_minor?(entity) && !actions.empty?
            actions
          end

          def corporation_actions(corporation)
            return [] unless can_convert?(corporation, current_entity)

            %w[convert pass]
          end

          def can_buy_any_from_ipo?(entity)
            return false unless @game.major_phase?

            super
          end

          def can_buy?(entity, bundle)
            # During conversion lock-in: only the new major's IPO is available.
            return false if @converted && bundle.corporation != @converted

            # During pre-conversion window: restrict to the converting regional only.
            # §9.3 step 1: president-only, one share max from the converting corp.
            if @converting
              return false if bundle.corporation != @converting
              return false unless bundle.corporation.president?(entity)
              return false if bought_corporation == bundle.corporation
            end

            super
          end

          def can_sell?(entity, bundle)
            return false unless bundle
            return false if bundle.corporation.type == :regional
            return false if bundle.corporation == @converted

            super
          end

          def can_sell_order?
            return true if @converted

            super
          end

          def can_float_minor?(entity)
            return false unless entity.player?

            !bought? && entity.companies.any? { |company| @game.company_becomes_minor?(company) }
          end

          def can_convert_any?(player)
            return false if @converting

            @game.corporations.any? { |corp| can_convert?(corp, player) }
          end

          def can_convert?(corporation, player)
            return false if @converting
            return false unless @game.major_phase?
            return false unless corporation.type == :regional
            return false if @sold
            return false if @converted
            # Conversion is its own action: no conversion after a normal share purchase.
            return false if bought?

            # Any player owning ≥50% (president's share, or both 25% non-president
            # shares) may trigger conversion.
            corporation.president?(player) || corporation.share_holders[player] >= 50
          end

          def float_major(corporation)
            # Step 1: Resize existing shares (50% president → 20%, 25% others → 10%)
            @game.shares_for_corporation(corporation).each do |share|
              share.percent = share.president ? 20 : 10
            end

            # Step 2: Recompute share_holders percentages from the resized shares
            corporation.share_holders.each_key do |sh|
              corporation.share_holders[sh] = sh.shares_by_corporation[corporation].sum(&:percent)
            end

            # Step 3: Locate the major par cell (right×2, up×1 from original par)
            # Using original_par_price ensures correct placement even if the regional
            # somehow moved before conversion.
            target_price = @game.stock_market.find_relative_share_price(
              corporation.original_par_price, corporation, %i[right right up]
            )

            # Step 4: Move stock market token to major par cell and update par_price.
            # Directly calling move() avoids relying on three incremental moves from
            # the current position (which can drift if price was ever touched).
            @game.stock_market.move(corporation, target_price.coordinates)
            corporation.par_price = target_price

            # Step 5: Promote to major (do this after price moves so move logic
            # doesn't see a half-converted corporation)
            corporation.type = :major

            # Step 6: Issue the 6 new 10% IPO shares.
            # add_new_share registers each share in @_shares immediately, keeping
            # the share cache consistent for all subsequent can_buy? checks.
            @game.class::CONVERSION_NEW_SHARES.times do |index|
              share = Share.new(corporation, owner: corporation.ipo_owner, percent: 10, index: 4 + index)
              @game.add_new_share(share)
            end

            corporation.tokens.concat([40, 60, 60, 80, 80, 80].map { |price| Engine::Token.new(corporation, price: price) })
            @game.minor_regional_order -= [corporation]
          end

          def help
            if @converted && !@converted.president?(current_entity)
              return "#{current_entity.name} must purchase one share of #{@converted.name} to become president."
            end

            return super unless can_float_minor?(current_entity)

            zones_display = @game.minor_available_regions.map { |zone, count| "#{zone}(#{count})" }.join(', ')
            "Available track rights zones: #{zones_display}. "\
              'Home station placement determines which zone the minor receives.'
          end

          def float_minor(action)
            share_price = action.share_price
            corporation = action.corporation
            entity = action.entity
            company = find_minor_company(corporation)

            @log << "#{entity.name} floats #{company.sym}"
            zones_display = @game.minor_available_regions.map { |zone, count| "#{zone}(#{count})" }.join(', ')
            @log << "Available track rights zones: #{zones_display}"

            @game.stock_market.set_par(corporation, share_price)
            share = corporation.ipo_shares.first
            @round.players_bought[entity][corporation] += share.percent
            buy_shares(entity, share.to_bundle, exchange: company, silent: true)
            company.close!
            track_action(action, action.corporation)
          end

          def find_minor_company(minor)
            @game.companies.find { |c| c.id == minor.id }
          end

          def ipo_type(entity)
            if entity.type == :minor && current_entity.companies.include?(find_minor_company(entity))
              :form
            elsif entity.type == :minor
              'Must have bought minor in auction phase'
            else
              :par
            end
          end

          def visible_corporations
            @game.sorted_corporations.reject { |c| (c.type == :minor && c.ipoed) }
          end

          def process_sell_shares(action)
            super
            @sold = true
          end

          def process_convert(action)
            @converting = action.entity
            @trigger_is_president = @converting.president?(current_entity)
            track_action(action, action.entity)
            @log << "#{current_entity.name} triggers conversion of #{action.entity.name}"
          end

          def process_par(action)
            if action.corporation.type == :minor
              float_minor(action)
            else
              super
              @game.regional_corps_floated += 1
            end

            @game.minor_regional_order << action.corporation

            return unless @game.regional_corps_floated == @game.class::MAX_FLOATED_REGIONALS

            corps = @game.corporations.dup
            corps.each do |corp|
              next if corp.ipoed || corp.type == :minor

              @game.close_corporation(corp)
            end

            pass!
          end

          def get_par_prices(entity, corp)
            return super unless corp.type == :minor

            @game.stock_market.par_prices
          end

          def check_legal_buy(entity, shares, exchange: nil, swap: nil, allow_president_change: true)
            raise GameError, "Cannot buy a share of #{shares&.corporation&.name}" if
              !can_buy?(entity, shares.to_bundle) && !swap && !exchange
          end

          def pass!
            if @converting
              # complete_conversion sets @converted and clears @converting.
              # Do NOT raise here: a non-president converter still needs to buy
              # one share to become president before passing their final turn.
              complete_conversion
              return
            end

            if @converted
              # Player must be president before ending their turn.
              raise GameError, "Must become president of newly floated major #{@converted&.name}" unless
                @converted.president?(current_entity)

              # Clear current_actions before calling super so the base pass! logic
              # sees an "empty turn" and calls entity.pass! (marking the player as
              # done) rather than entity.unpass! (which would give them another
              # full SR turn for having done Convert+BuyShares this turn).
              @round.current_actions.clear
              @converted = nil
            end

            super
          end

          def log_pass(entity)
            return if bought?

            @log << "#{entity.name} passes"
          end

          private

          def converting_actions(entity)
            actions = []
            ipo_bundle = @converting.ipo_shares.first&.to_bundle
            actions << 'buy_shares' if ipo_bundle && can_buy?(entity, ipo_bundle)
            actions << 'pass'
            actions
          end

          def converted_actions(entity)
            actions = []
            actions << 'sell_shares' if can_sell_any?(entity)
            unless bought?
              ipo_bundle = @converted.ipo_shares.first&.to_bundle
              actions << 'buy_shares' if ipo_bundle && can_buy?(entity, ipo_bundle)
            end
            actions << 'pass' if @trigger_is_president || bought?
            actions
          end

          def bought_corporation
            @round.current_actions.find { |x| x.is_a?(Action::BuyShares) }&.bundle&.corporation
          end

          def complete_conversion
            corporation = @converting
            float_major(corporation)
            @converted = corporation
            @converting = nil
            @log << "#{corporation.name} converts from regional to major"
          end
        end
      end
    end
  end
end
