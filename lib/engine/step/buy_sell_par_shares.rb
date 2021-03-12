# frozen_string_literal: true

require_relative 'base'
require_relative 'share_buying'
require_relative 'programmer'
require_relative '../action/buy_company'
require_relative '../action/buy_shares'
require_relative '../action/par'

module Engine
  module Step
    class BuySellParShares < Base
      include ShareBuying
      include Programmer

      PURCHASE_ACTIONS = [Action::BuyCompany, Action::BuyShares, Action::Par].freeze

      def actions(entity)
        return [] unless entity == current_entity
        return ['sell_shares'] if must_sell?(entity)

        actions = []
        actions << 'buy_shares' if can_buy_any?(entity)
        actions << 'par' if can_ipo_any?(entity)
        actions << 'buy_company' unless purchasable_companies(entity).empty?
        actions << 'sell_shares' if can_sell_any?(entity)

        actions << 'pass' unless actions.empty?
        actions
      end

      def log_pass(entity)
        return @log << "#{entity.name} passes" if @round.current_actions.empty?
        return if bought? && sold?

        action = bought? ? 'to sell' : 'to buy'
        @log << "#{entity.name} declines #{action} shares"
      end

      def log_skip(entity)
        @log << "#{entity.name} has no valid actions and passes"
      end

      def description
        case @game.class::SELL_BUY_ORDER
        when :sell_buy_or_buy_sell
          'Buy or Sell Shares'
        when :sell_buy
          'Sell then Buy Shares'
        when :sell_buy_sell
          'Sell/Buy/Sell Shares'
        end
      end

      def pass_description
        if @round.current_actions.empty?
          'Pass (Share)'
        else
          'Done (Share)'
        end
      end

      def round_state
        {
          # What the player has sold/shorted since the start of the round
          players_sold: Hash.new { |h, k| h[k] = {} },
          # Actions taken by the player on this turn
          current_actions: [],
          # What the player did last turn
          players_history: Hash.new { |h, k| h[k] = Hash.new { |h2, k2| h2[k2] = [] } },
        }
      end

      def setup
        # player => corporation => :now or :prev
        # this differentiates between preventing users from buying shares they sold
        # and preventing users from selling the same shares separately in the some action
        @round.players_sold.each do |_player, corps|
          corps.each { |corp, _k| corps[corp] = :prev }
        end

        @round.players_history[current_entity].clear

        @round.current_actions = []
      end

      # Returns if a share can be bought via a normal buy actions
      # If a player has sold shares they cannot buy in many 18xx games
      # Some 18xx games can only buy one share per turn.
      def can_buy?(entity, bundle)
        return unless bundle&.buyable

        corporation = bundle.corporation
        entity.cash >= bundle.price &&
          !@round.players_sold[entity][corporation] &&
          (can_buy_multiple?(entity, corporation) || !bought?) &&
          can_gain?(entity, bundle)
      end

      def must_sell?(entity)
        return false if @game.can_hold_above_limit?(entity)
        return false unless can_sell_any?(entity)

        @game.num_certs(entity) > @game.cert_limit ||
          !@game.corporations.all? { |corp| corp.holding_ok?(entity) }
      end

      def can_sell?(entity, bundle)
        return unless bundle

        corporation = bundle.corporation

        timing = @game.check_sale_timing(entity, corporation)

        timing &&
          !(@game.class::MUST_SELL_IN_BLOCKS && @round.players_sold[entity][corporation] == :now) &&
          can_sell_order? &&
          @game.share_pool.fit_in_bank?(bundle) &&
          bundle.can_dump?(entity)
      end

      def can_sell_order?
        case @game.class::SELL_BUY_ORDER
        when :sell_buy_or_buy_sell
          !(@round.current_actions.uniq(&:class).size == 2 &&
            self.class::PURCHASE_ACTIONS.include?(@round.current_actions.last.class))
        when :sell_buy
          !bought?
        when :sell_buy_sell
          true
        end
      end

      def did_sell?(corporation, entity)
        @round.players_sold[entity][corporation]
      end

      def last_acted_upon?(corporation, entity)
        !@round.players_history[entity][corporation]&.empty?
      end

      def track_action(action, corporation, player_action = true)
        @round.last_to_act = action.entity.player
        @round.current_actions << action if player_action
        @round.players_history[action.entity.player][corporation] << action
      end

      def process_buy_shares(action)
        buy_shares(action.entity, action.bundle, swap: action.swap)
        track_action(action, action.bundle.corporation)
      end

      def process_sell_shares(action)
        sell_shares(action.entity, action.bundle, swap: action.swap)
        track_action(action, action.bundle.corporation)
      end

      def process_par(action)
        share_price = action.share_price
        corporation = action.corporation
        entity = action.entity
        raise GameError, "#{corporation.name} cannot be parred" unless @game.can_par?(corporation, entity)

        @game.stock_market.set_par(corporation, share_price)
        share = corporation.shares.first
        buy_shares(entity, share.to_bundle)
        @game.after_par(corporation)
        track_action(action, action.corporation)
      end

      def pass!
        super
        if @round.current_actions.any?
          @round.pass_order.delete(current_entity)
          current_entity.unpass!
        else
          @round.pass_order |= [current_entity]
          current_entity.pass!
        end
      end

      def can_buy_multiple?(_entity, corporation)
        corporation.buy_multiple? &&
         @round.current_actions.none? { |x| x.is_a?(Action::Par) } &&
         @round.current_actions.none? { |x| x.is_a?(Action::BuyShares) && x.bundle.corporation != corporation }
      end

      def can_sell_any?(entity)
        @game.corporations.any? do |corporation|
          bundles = @game.bundles_for_corporation(entity, corporation)
          bundles.any? { |bundle| can_sell?(entity, bundle) }
        end
      end

      def can_buy_shares?(entity, shares)
        return false if shares.empty?

        corporation = shares.first.corporation
        return false if @round.players_sold[entity][corporation] || (bought? && !can_buy_multiple?(entity, corporation))

        min_share = nil
        shares.each do |share|
          next unless share.buyable

          min_share = share if !min_share || share.percent < min_share.percent
        end

        bundle = min_share&.to_bundle
        return unless bundle

        entity.cash >= bundle.price && can_gain?(entity, bundle)
      end

      def can_buy_any_from_market?(entity)
        @game.share_pool.shares.group_by(&:corporation).each do |_, shares|
          return true if can_buy_shares?(entity, shares)
        end

        false
      end

      def can_buy_any_from_ipo?(entity)
        @game.corporations.each do |corporation|
          next unless corporation.ipoed
          return true if can_buy_shares?(entity, corporation.shares)
        end

        false
      end

      def can_buy_any?(entity)
        (can_buy_any_from_market?(entity) ||
        can_buy_any_from_ipo?(entity))
      end

      def can_ipo_any?(entity)
        !bought? && @game.corporations.any? do |c|
          @game.can_par?(c, entity) && can_buy?(entity, c.shares.first&.to_bundle)
        end
      end

      def ipo_type(_entity)
        :par
      end

      def purchasable_companies(entity)
        return [] if bought? ||
          !entity.cash.positive? ||
          !@game.phase.status.include?('can_buy_companies_from_other_players')

        @game.purchasable_companies(entity)
      end

      def get_par_prices(entity, _corp)
        @game
          .stock_market
          .par_prices
          .select { |p| p.price * 2 <= entity.cash }
      end

      def sell_shares(entity, shares, swap: nil)
        raise GameError, "Cannot sell shares of #{shares.corporation.name}" if !can_sell?(entity, shares) && !swap

        @round.players_sold[shares.owner][shares.corporation] = :now
        @game.sell_shares_and_change_price(shares, swap: swap)
      end

      def bought?
        @round.current_actions.any? { |x| self.class::PURCHASE_ACTIONS.include?(x.class) }
      end

      def sold?
        @round.current_actions.any? { |x| x.instance_of?(Action::SellShares) }
      end

      def process_buy_company(action)
        entity = action.entity
        company = action.company
        price = action.price
        owner = company.owner

        raise GameError, "Cannot buy #{company.name} from #{owner.name}" if owner&.corporation?

        company.owner = entity
        owner&.companies&.delete(company)

        entity.companies << company
        entity.spend(price, owner.nil? ? @game.bank : owner)
        @round.current_actions << action
        @log << "#{owner ? '-- ' : ''}#{entity.name} buys #{company.name} from "\
                "#{owner ? owner.name : 'the market'} for #{@game.format_currency(price)}"
      end

      def auto_actions(entity)
        programmed_auto_actions(entity)
      end

      def corporation_secure_percent
        # Most games 50% is fine, those where it's not (e.g. 1817) should subclass
        50
      end

      def corporation_secure?(corporation)
        # Can any other player steal the corporation?

        (corporation.owner.percent_of(corporation, ceil: false)) >= corporation_secure_percent
      end

      def action_is_shenanigan?(entity, action, corporation, share_to_buy)
        corp_buying = share_to_buy&.corporation

        if action.is_a?(Action::Par)

          # If the player can sell shares or they're passing
          # they may wish to manipulate share price
          "Corporation #{corporation.name} parred" if !corp_buying || @game.check_sale_timing(entity, corporation)
        elsif action.is_a?(Action::BuyShares)
          if corporation.owner == entity
            return if corporation_secure?(corporation) # Don't care...

            unless corporation == corp_buying
              return "#{action.entity.player.name} bought on corporation #{corporation.name} and is unsecure"
            end

            percentage = corporation.owner.percent_of(corporation, ceil: false) + share_to_buy.percent
            # If next share is bought, is the corp secure? Then it's safe to buy...
            return if percentage > corporation_secure_percent

            # 1849: Don't automatically buy if shares that could potentially be purchased
            # Owner has 20% and buys 10%, Other Entity 20% and could buy the 20% becoming president
            # For simplicity this finds all shares that could potentially make the other player president
            # it doesn't care where that share is (except for the current president))

            # This assumes there's only one buy per round for other games this needs reexamining.
            # This doesn't protect against potential brown exploits, players should have already spotted it's
            # in the brown and made decisions appropriately.
            bigger_share = @game.shares_for_corporation(corporation).select do |s|
              s.percent > share_to_buy.percent && (s.owner != entity || s.owner != corporation.owner)
            end.max(&:percent)

            if bigger_share
              other_percent = action.entity.percent_of(corporation, ceil: false) + bigger_share.percent
              if percentage < other_percent
                "#{action.entity.player.name} has bought, shares exist that could allow them to gain presidency"
              end
            end
          end
        elsif action.is_a?(Action::SellShares)
          'Shares were sold'
        else
          "Unknown action #{action.type} disabling for safety"
        end
      end

      def should_stop_applying_program(entity, share_to_buy)
        # check for shenanigans, returning the first failure reason it finds
        @round.players_history.each do |other_entity, corporations|
          next if other_entity == entity

          corporations.each do |corporation, actions|
            actions.each do |action|
              reason = action_is_shenanigan?(entity, action, corporation, share_to_buy)
              return reason if reason
            end
          end
        end
        nil
      end

      def normal_pass?(_entity)
        # If the user passes now is it a 'normal' pass? i.e. if it's not inside a bid
        # not price protection or something similar
        true
      end

      def activate_program_share_pass(entity, _program)
        available_actions = actions(entity)
        return unless available_actions.include?('pass')
        return unless normal_pass?(entity)

        reason = should_stop_applying_program(entity, nil)
        return [Action::ProgramDisable.new(entity, reason: reason)] if reason

        [Action::Pass.new(entity)]
      end

      def activate_program_buy_shares(entity, program)
        available_actions = actions(entity)
        if available_actions.include?('buy_shares')
          corporation = program.corporation

          # check if end condition met
          if program.until_condition == 'float'
            return [Action::ProgramDisable.new(entity,
                                               reason: "#{corporation.name} is floated")] if corporation.floated?
          elsif entity.num_shares_of(corporation, ceil: false) >= program.until_condition
            return [Action::ProgramDisable.new(entity,
                                               reason: "#{program.until_condition} share(s) bought in "\
                                               "#{corporation.name}, end condition met")]
          end
          shares_by_percent = if program.from_market
                                source = 'market'
                                @game.share_pool.shares_by_corporation[corporation]
                              else
                                source = @game.ipo_name(corporation)
                                corporation.ipo_shares
                              end.select { |share| can_buy?(entity, share) }.group_by(&:percent)

          if shares_by_percent.empty?
            return [Action::ProgramDisable.new(entity,
                                               reason: "Cannot buy #{corporation.name} from #{source}")]
          end

          if shares_by_percent.size != 1
            return [Action::ProgramDisable.new(entity,
                                               reason: 'Shares of different sizes exist, cannot auto buy'\
                                               " #{corporation.name} from #{source}")]
          end

          share = shares_by_percent.values.first.first

          reason = should_stop_applying_program(entity, share)
          return [Action::ProgramDisable.new(entity, reason: reason)] if reason

          [Action::BuyShares.new(entity, shares: share)]
        elsif bought? && available_actions.include?('pass')
          # Buy-then-Sell games need the pass
          [Action::Pass.new(entity)]
        end
      end
    end
  end
end
