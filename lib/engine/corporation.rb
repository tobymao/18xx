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
require_relative 'transfer'

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
    include Transfer

    attr_accessor :ipoed, :par_via_exchange, :max_ownership_percent, :float_percent, :capitalization
    attr_reader :companies, :min_price, :name, :full_name, :fraction_shares, :type
    attr_writer :par_price, :share_price

    SHARES = ([20] + Array.new(8, 10)).freeze

    def initialize(sym:, name:, **opts)
      @name = sym
      @full_name = name

      shares = (opts[:shares] || SHARES).map.with_index do |percent, index|
        Share.new(self, president: index.zero?, percent: percent, index: index)
      end

      shares.each { |share| shares_by_corporation[self] << share }
      @fraction_shares = shares.find { |s| (s.percent % 10).positive? }
      @presidents_share = shares.first
      @second_share = shares[1]

      @share_price = nil
      @par_price = nil
      @ipoed = false
      @companies = []

      @cash = 0
      @capitalization = opts[:capitalization] || :full
      @closed = false
      @float_percent = opts[:float_percent] || 60
      @floated = false
      @max_ownership_percent = opts[:max_ownership_percent] || 60
      @can_hold_above_max = opts[:can_hold_above_max] || false
      @min_price = opts[:min_price]
      @always_market_price = opts[:always_market_price] || false
      @needs_token_to_par = opts[:needs_token_to_par] || false
      @par_via_exchange = nil
      @type = opts[:type]

      init_abilities(opts[:abilities])
      init_operator(opts)
    end

    def <=>(other)
      # corporation with higher share price, farthest on the right, and first position on the share price goes first
      return 1 unless (sp = share_price)
      return -1 unless (ops = other.share_price)

      [ops.price, ops.coordinates.last, -ops.coordinates.first, -ops.corporations.find_index(other)] <=>
      [sp.price, sp.coordinates.last, -sp.coordinates.first, -sp.corporations.find_index(self)]
    end

    def counts_for_limit
      # if no share price, like when you exchange a share pre-ipo
      # it still counts
      @share_price ? @share_price.counts_for_limit : true
    end

    def buy_multiple?
      @share_price ? @share_price.buy_multiple? : false
    end

    def can_par?(entity)
      return false if @par_via_exchange && @par_via_exchange.owner != entity
      return false if @needs_token_to_par && @tokens.empty?

      !@ipoed
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
      num_shares_of(self)
    end

    def reserved_shares
      shares_by_corporation[self].reject(&:buyable)
    end

    def num_ipo_reserved_shares
      reserved_shares.sum(&:percent) / share_percent
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

    def player_share_holders
      share_holders.select { |s_h, _| s_h.player? }
    end

    def corporate_share_holders
      share_holders.select { |s_h, _| s_h.corporation? && s_h != self }
    end

    def corporate_shares
      shares.reject { |share| share.corporation == self }
    end

    def id
      @name
    end

    def president?(player)
      return false unless player

      owner == player
    end

    def floated?
      @floated ||= percent_of(self) <= 100 - @float_percent
    end

    def percent_to_float
      @floated ? 0 : percent_of(self) - (100 - @float_percent)
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
      return true if @can_hold_above_max

      percent = share_holder.percent_of(self) + extra_percent
      %i[multiple_buy unlimited].include?(@share_price&.type) || percent <= @max_ownership_percent
    end

    def all_abilities
      @companies.flat_map(&:all_abilities) + @abilities
    end

    def remove_ability(ability)
      return super if ability.owner == self

      @companies.each { |company| company.remove_ability(ability) }
    end

    def abilities(type = nil, **opts)
      abilities = []

      if (ability = super(type, **opts, &nil))
        abilities << ability
        yield ability, self if block_given?
      end

      @companies.each do |company|
        company.abilities(type, **opts) do |company_ability|
          abilities << company_ability
          yield company_ability, company if block_given?
        end
      end

      abilities
    end

    def available_share
      shares_by_corporation[self].find { |share| !share.president }
    end

    def presidents_percent
      @presidents_share.percent
    end

    def share_percent
      @second_share&.percent || presidents_percent / 2
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
  end
end
