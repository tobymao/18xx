# frozen_string_literal: true

require_relative 'abilities'
require_relative 'assignable'
require_relative 'entity'
require_relative 'operator'
require_relative 'ownable'
require_relative 'passer'
require_relative 'share'
require_relative 'share_holder'
require_relative 'spender'
require_relative 'token'

module Engine
  class Corporation
    include Abilities
    include Assignable
    include Entity
    include Operator
    include Ownable
    include Passer
    include ShareHolder
    include Spender

    attr_accessor :ipoed, :floated, :par_via_exchange, :max_ownership_percent, :float_percent, :capitalization, :second_share,
                  :type, :floatable, :original_par_price, :reservation_color, :min_price, :ipo_owner,
                  :always_market_price, :full_name
    attr_reader :companies, :name, :fraction_shares, :id, :needs_token_to_par,
                :presidents_share, :price_multiplier, :treasury_as_holding
    attr_writer :par_price, :share_price, :forced_share_percent

    SHARES = ([20] + Array.new(8, 10)).freeze

    def initialize(sym:, name:, **opts)
      @name = sym
      @id = sym
      @full_name = name

      @ipo_owner = opts[:ipo_owner] || self
      corp_shares = (opts[:shares] || SHARES).map.with_index do |percent, index|
        Share.new(self, owner: @ipo_owner, president: index.zero?, percent: percent, index: index)
      end
      corp_shares.each { |share| @ipo_owner.shares_by_corporation[self] << share }
      share_holders[@ipo_owner] = corp_shares.sum(&:percent)

      @fraction_shares = if opts.key?(:fraction_shares)
                           opts[:fraction_shares]
                         else
                           corp_shares.find do |s|
                             (s.percent % 10).positive?
                           end
                         end

      @presidents_share = corp_shares.first
      @second_share = corp_shares[1]

      @share_price = nil
      @par_price = nil
      @original_par_price = nil
      @ipoed = false
      @companies = []

      @cash = 0
      @capitalization = opts[:capitalization] || :full
      @closed = false
      @float_percent = opts[:float_percent] || 60
      @float_excludes_market = opts[:float_excludes_market] || false
      @float_includes_reserved = opts[:float_includes_reserved] || false
      @floatable = opts[:floatable].nil? ? true : opts[:floatable]
      @floated = false
      @max_ownership_percent = opts[:max_ownership_percent] || 60
      @min_price = opts[:min_price]
      @always_market_price = opts[:always_market_price] || false
      @needs_token_to_par = opts[:needs_token_to_par] || false
      @par_via_exchange = nil
      @type = opts[:type]&.to_sym
      @hide_shares = opts[:hide_shares] || false
      @reservation_color = opts[:reservation_color]
      @price_percent = opts[:price_percent] || @second_share&.percent || (@presidents_share.percent / 2)
      @price_multiplier = (@second_share&.percent || (@presidents_share.percent / 2)) / @price_percent
      @treasury_as_holding = opts[:treasury_as_holding] || false
      @corporation_can_ipo = opts[:corporation_can_ipo]

      init_abilities(opts[:abilities])
      init_operator(opts)
    end

    # This is used to allow "Buying power" to be rendered
    def can_buy?
      true
    end

    def <=>(other)
      return -1 unless (self_key = sort_order_key)
      return 1 unless (other_key = other.sort_order_key)

      self_key <=> other_key
    end

    # sort in operating order, then name: corporation with higher share price,
    # farthest on the right, and first position on the share price goes first
    def sort_order_key
      return unless (sp = share_price)

      [-sp.price, -sp.coordinates.last, sp.coordinates.first, (sp.corporations.find_index(self) || 0), name]
    end

    def counts_for_limit
      # if no share price, like when you exchange a share pre-ipo
      # it still counts
      @share_price ? @share_price.counts_for_limit : true
    end

    def buy_multiple?
      @share_price ? @share_price.buy_multiple? : false
    end

    def hide_shares?
      @hide_shares
    end

    def share_price
      return if closed?

      @share_price
    end

    def par_price
      return if closed?

      @always_market_price ? @share_price : @par_price
    end

    def total_shares
      100 / share_percent
    end

    def num_ipo_shares
      @ipo_owner.num_shares_of(self)
    end

    def reserved_shares
      @ipo_owner.shares_by_corporation[self].reject(&:buyable)
    end

    def num_ipo_reserved_shares
      reserved_shares.sum(&:percent) / share_percent
    end

    def num_treasury_shares
      @treasury_as_holding ? 0 : num_shares_of(self)
    end

    def num_player_shares
      player_share_holders.values.sum / share_percent
    end

    def num_corporate_shares
      corporate_share_holders.values.sum / share_percent
    end

    def num_market_shares
      share_holders.select { |s_h, _| s_h.share_pool? }.values.sum / share_percent
    end

    def share_holders
      @share_holders ||= Hash.new(0)
    end

    def player_share_holders(corporate: false)
      share_holders.select do |s_h, _|
        s_h.player? || ((corporate || @corporation_can_ipo) && s_h.corporation? && s_h != self)
      end
    end

    def ipo_is_treasury?
      @ipo_owner == self
    end

    def corporate_share_holders
      share_holders.select { |s_h, _| s_h.corporation? && (s_h != self || @treasury_as_holding) }
    end

    def corporate_shares
      shares.reject { |share| share.corporation == self && !@treasury_as_holding }
    end

    def ipo_shares
      @ipo_owner.shares.select { |share| share.corporation == self }
    end

    def treasury_shares
      shares.select { |share| share.corporation == self && !@treasury_as_holding }
    end

    def president?(player)
      return false unless player

      owner == player
    end

    def floated?
      return false unless @floatable

      @floated ||= @ipo_owner.percent_of(self) <= (
        100 - @float_percent -
        (@float_excludes_market ? percent_in_market : 0) +
        (@float_includes_reserved ? percent_in_reserved : 0))
    end

    def percent_to_float
      return 0 if @floated

      @ipo_owner.percent_of(self) -
        (100 - @float_percent -
         (@float_excludes_market ? percent_in_market : 0) +
         (@float_includes_reserved ? percent_in_reserved : 0))
    end

    def percent_in_market
      num_market_shares * share_percent
    end

    def percent_in_reserved
      num_ipo_reserved_shares * share_percent
    end

    def unfloat!
      @floated = false
    end

    def corporation?
      true
    end

    def receivership?
      owner&.share_pool?
    end

    def inspect
      "<#{self.class.name}: #{id}>"
    end

    # Is it legal to hold percent shares in this corporation?
    def holding_ok?(share_holder, extra_percent = 0)
      common_percent = share_holder.common_percent_of(self) + extra_percent
      %i[multiple_buy unlimited].include?(@share_price&.type) || common_percent <= @max_ownership_percent
    end

    def all_abilities
      all_abilities = @companies.flat_map(&:all_abilities) + @abilities
      if owner.respond_to?(:companies)
        all_abilities += owner.companies&.flat_map do |c|
          c.all_abilities.select do |a|
            a.when.to_s.include? 'owning_player'
          end
        end
      end
      all_abilities
    end

    def remove_ability(ability)
      return super if ability.owner == self

      @companies.each { |company| company.remove_ability(ability) }
    end

    def available_share
      shares_by_corporation[self].find { |share| !share.president }
    end

    def presidents_percent
      @presidents_share.percent
    end

    def share_percent
      @forced_share_percent || @second_share&.percent || (presidents_percent / 2)
    end

    # avoid infinite recursion for 1841
    def player
      chain = { owner => true }
      current = owner
      while current&.corporation?
        return nil unless current&.owner # unowned corp

        current = current.owner
        return nil if chain[current] # cycle detected

        chain[current] = true
      end
      current&.player? ? current : current&.player
    end

    def closed?
      @closed
    end

    def close!
      share_price&.corporations&.delete(self)
      @closed = true
      @ipoed = false
      @floated = false
      @owner = nil
    end

    def reopen!
      @closed = false
    end
  end
end
