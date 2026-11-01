# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'
require_relative '../../../action/convert'
require_relative '../../../action/choose'

module Engine
  module Game
    module G18OE
      module Step
        class BuySellParShares < Engine::Step::BuySellParShares
          PURCHASE_ACTIONS = Engine::Step::BuySellParShares::PURCHASE_ACTIONS + [Action::Choose]

          def round_state
            super.merge(merge_minor: nil, merged_majors: [])
          end

          def setup
            super

            @converting = nil
            @converted = nil

            @sold = false
            @private_action_used = false
          end

          def actions(entity)
            return corporation_actions(entity) if entity.corporation?
            return [] unless entity == current_entity
            return must_sell_actions(entity) if must_sell?(entity) || must_reduce_privates?(entity)
            return converting_actions(entity) if @converting
            return converted_actions(entity) if @converted

            actions = []
            actions << 'buy_shares' if can_buy_any?(entity)
            actions << 'par' if can_ipo_any?(entity) || can_float_minor?(entity)
            actions << 'buy_company' if !purchasable_companies(entity).empty? || !buyable_bank_owned_companies(entity).empty?
            actions << 'sell_shares' if can_sell_any?(entity)
            actions << 'choose' if choose_available?(entity)
            actions << 'pass' if !can_float_minor?(entity) && !actions.empty?
            actions
          end

          def must_sell_actions(entity)
            actions = []
            actions << 'sell_shares' if can_sell_any?(entity)
            actions << 'choose' if can_act_on_any_private?(entity)
            actions
          end

          def must_reduce_privates?(entity)
            return false unless over_certificate_limit?(entity)

            entity.companies.any? { |company| can_act_on_private?(entity, company) && !@game.face_down_private?(company) }
          end

          def choose_available?(entity)
            return can_act_on_any_private?(entity) unless non_private_choices_allowed?(entity)

            can_merge_any?(entity) || can_remove_any_corporation?(entity) || can_reserve_any?(entity) ||
              can_act_on_any_private?(entity)
          end

          def can_act_on_any_private?(player)
            player.companies.any? { |company| can_act_on_private?(player, company) }
          end

          def can_act_on_private?(player, company)
            return false if @game.face_down_private?(company)

            @game.private_company?(company) && company.owner == player && player == current_entity &&
              !@private_action_used && @round.current_actions.empty?
          end

          def can_merge_any?(player)
            @game.corporations.any? { |corporation| corporation.type == :minor && can_merge?(player, corporation) }
          end

          def over_certificate_limit?(player)
            @game.num_certs(player) > @game.cert_limit(player)
          end

          def non_private_choices_allowed?(player)
            !over_certificate_limit?(player)
          end

          def can_merge?(player, minor)
            @round.current_actions.empty? && !@game.merge_targets(player, minor).empty?
          end

          def can_remove_any_corporation?(player)
            @game.corporations.any? { |corporation| can_remove_corporation?(player, corporation) }
          end

          def can_remove_corporation?(_player, corporation)
            @round.current_actions.empty? && @game.removable_regional?(corporation)
          end

          def can_reserve_any?(player)
            @game.corporations.any? { |corporation| can_reserve?(player, corporation) }
          end

          def can_reserve?(player, corporation)
            @game.can_reserve_regional?(player, corporation)
          end

          def pass_description
            return super if @round.current_actions.empty?
            return super unless (actions(current_entity) - %w[choose pass]).empty?

            'Pass (Reserve Share)'
          end

          def choice_available?(entity)
            (entity.corporation? || entity.company?) && !entity_choices(entity).empty?
          end

          def choice_companies(player)
            return [] unless player.player?

            @game.companies_sort(player.companies).select { |company| choice_available?(company) }
          end

          def choice_name
            nil
          end

          def entity_choices(target)
            return private_choices(target) if target.company?
            return {} unless non_private_choices_allowed?(current_entity)

            corporation = target
            choices = {}
            choices['remove'] = 'Remove from game' if can_remove_corporation?(current_entity, corporation)
            choices['reserve'] = 'Reserve share' if can_reserve?(current_entity, corporation)
            choices
          end

          def private_choices(company)
            return {} unless can_act_on_private?(current_entity, company)

            choices = { 'remove_private' => 'Remove from game' }
            choices['flip_private'] = 'Flip face down' unless @game.face_down_private?(company)
            choices
          end

          def process_choose(action)
            return process_private_choice(action) if action.target&.company?
            raise GameError, "Cannot choose #{action.choice} while above the certificate limit" unless
              non_private_choices_allowed?(action.entity)

            return remove_regional(action) if action.target && action.choice == 'remove'
            return reserve_regional(action) if action.target && action.choice == 'reserve'

            minor = @game.corporation_by_id(action.choice)
            raise GameError, "Cannot merge #{action.choice}" if !minor || !can_merge?(action.entity, minor)

            @round.merge_minor = minor
            track_action(action, minor)
          end

          def process_private_choice(action)
            player = action.entity
            company = action.target
            raise GameError, "Cannot #{action.choice} #{company.name}" unless private_choices(company).key?(action.choice)

            if action.choice == 'flip_private'
              @log << "#{player.name} turns #{company.name} face down"
              @game.flip_private!(company)
            else
              @log << "#{player.name} removes #{company.name} from the game"
              @game.remove_private!(company)
            end
            @private_action_used = true
          end

          def remove_regional(action)
            regional = action.target
            raise GameError, "Cannot remove #{regional.id}" unless can_remove_corporation?(action.entity, regional)

            @log << "#{action.entity.name} removes #{regional.name} from the game"
            @game.remove_regional!(regional)
            track_action(action, regional)
          end

          def reserve_regional(action)
            regional = action.target
            player = action.entity
            raise GameError, "Cannot reserve #{regional.name}" unless can_reserve?(player, regional)

            @log << "#{player.name} reserves a share of #{regional.name}"
            @game.reserve_share!(regional)
          end

          def reservation_prompt?(action)
            return false unless @game.reserved_shares?
            return false if @game.turn != 1 || @converting || @round.pending_share_buy

            bundle = action.bundle
            corporation = bundle.corporation
            return false if corporation.type != :regional || bundle.presidents_share
            return false if bundle.owner != corporation.ipo_owner || corporation.owner == action.entity

            @game.can_reserve_regional?(corporation.owner, corporation)
          end

          def process_buy_shares(action)
            return super unless reservation_prompt?(action)

            check_legal_buy(action.entity, action.bundle, swap: action.swap)
            @round.pending_share_buy = action
          end

          def corporation_actions(corporation)
            return [] unless can_convert?(corporation, current_entity)

            %w[convert pass]
          end

          def can_buy_any_from_ipo?(entity)
            return super if @game.major_phase?

            @game.corporations.any? do |corporation|
              @game.parred_regional?(corporation) && can_buy?(entity, corporation.presidents_share.to_bundle)
            end
          end

          def can_buy?(entity, bundle)
            return false if treasury_share_off_sale?(bundle)
            return false if reserved_for_another?(entity, bundle)

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

          def can_gain?(entity, bundle, exchange: false)
            # §10.2: president buying own pool shares is allowed above the holding cap.
            # Bypass holding_ok?; all other checks (bought?, cash, cert limit) run via super.
            if bundle&.owner&.share_pool? && bundle.corporation.president?(entity)
              return !bundle.corporation.counts_for_limit || exchange || @game.num_certs(entity) < @game.cert_limit(entity)
            end

            super
          end

          def modify_purchase_price(bundle)
            return bundle.corporation.share_price.price * 2 if president_pool_overcap_buy?(current_entity, bundle)

            super
          end

          def can_sell?(entity, bundle)
            return false unless bundle
            return false if %i[regional minor].include?(bundle.corporation.type)
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
            @game.place_major_par_marker!(corporation)

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

            "Available track rights zones: #{zones_display}. "\
              'Home station placement determines which zone the minor receives.'
          end

          def float_minor(action)
            share_price = action.share_price
            corporation = action.corporation
            entity = action.entity
            company = find_minor_company(corporation)
            raise GameError, "#{entity.name} does not own #{company.name}" unless company.owner == entity

            @log << "#{entity.name} floats #{company.sym}"

            @game.par_corporation(corporation, share_price)
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
            minors, others = @game.sorted_corporations.partition { |corporation| corporation.type == :minor }
            others + minors
          end

          def process_sell_shares(action)
            super
            @sold = true
          end

          def process_convert(action)
            @converting = action.entity
            track_action(action, action.entity)
            @log << "#{current_entity.name} triggers conversion of #{action.entity.name}"
          end

          def process_par(action)
            if action.corporation.type == :minor
              float_minor(action)
            else
              super
            end

            @game.minor_regional_order << action.corporation

            close_unfloated_regionals_at_maximum!
          end

          def close_unfloated_regionals_at_maximum!
            return unless @game.regionals_in_play >= @game.class::MAX_FLOATED_REGIONALS

            leftovers = @game.corporations.reject { |corp| corp.ipoed || corp.type == :minor }
            return if leftovers.empty?

            leftovers.each { |corp| @game.close_corporation(corp) }

            pass!
          end

          def get_par_prices(entity, corp)
            prices = @game.stock_market.par_prices
            case corp.type
            when :minor
              prices
            when :regional
              affordable_regional_par_prices(entity)
            else
              super
            end
          end

          def affordable_regional_par_prices(entity)
            @game.stock_market.par_prices.select { |price| price.price * 2 <= available_cash(entity) }
          end

          def check_legal_buy(entity, shares, exchange: nil, swap: nil, allow_president_change: true)
            raise GameError, "Cannot buy a share of #{shares&.corporation&.name}" if
              !can_buy?(entity, shares.to_bundle) && !swap && !exchange
          end

          def pass!
            if @converting
              complete_conversion
              return
            end

            @converted = nil

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
            actions << 'pass' if @converted.president?(entity)
            actions
          end

          def zones_display
            @game.minor_available_regions.map { |zone, count| "#{zone}(#{count})" }.join(', ')
          end

          def bought_corporation
            @round.current_actions.find { |x| x.is_a?(Action::BuyShares) }&.bundle&.corporation
          end

          def reserved_for_another?(entity, bundle)
            return false unless bundle

            corporation = bundle.corporation
            bundle.shares.include?(@game.reserved_share(corporation)) && entity != corporation.owner
          end

          def treasury_share_off_sale?(bundle)
            return false if @game.major_phase? || !bundle

            corporation = bundle.corporation
            return false if bundle.owner != corporation.ipo_owner || !corporation.ipoed

            !(@game.parred_regional?(corporation) && bundle.presidents_share && bundle.percent == corporation.presidents_percent)
          end

          def president_pool_overcap_buy?(entity, bundle)
            return false unless bundle&.owner&.share_pool?

            corp = bundle.corporation
            return false unless %i[major national].include?(corp.type)
            return false unless corp.president?(entity)

            entity.common_percent_of(corp) >= 60
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
