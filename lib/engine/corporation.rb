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

    attr_accessor :ipoed, :share_price, :par_via_exchange
    attr_reader :capitalization, :companies, :min_price, :name, :full_name, :total_shares
    attr_writer :par_price

    def initialize(sym:, name:, **opts)
      @name = sym
      @full_name = name
      shares = [
        Share.new(self, president: true, percent: 20),
        *8.times.map { |index| Share.new(self, percent: 10, index: index + 1) },
      ]
      shares.each { |share| shares_by_corporation[self] << share }
      @presidents_share = shares.first
      @second_share = shares[1]

      @share_price = nil
      @par_price = nil
      @ipoed = false
      @companies = []

      @cash = 0
      @capitalization = opts[:capitalization] || :full
      @float_percent = opts[:float_percent] || 60
      @max_ownership_percent = opts[:max_ownership_percent] || 60
      @min_price = opts[:min_price]
      @always_market_price = opts[:always_market_price] || false
      @needs_token_to_par = opts[:needs_token_to_par] || false
      @total_shares = opts[:total_shares] || 10
      @par_via_exchange = nil

      init_abilities(opts[:abilities])
      init_operator(opts)
    end

    def <=>(other)
      # corporation with higher share price, farthest on the right, and first position on the share price goes first
      sp = share_price
      ops = other.share_price
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

    def par_price
      @always_market_price ? @share_price : @par_price
    end

    def num_ipo_shares
      num_shares_of(self)
    end

    def num_player_shares
      player_share_holders.values.sum / @total_shares
    end

    def num_market_shares
      share_holders.select { |s_h, _| s_h.share_pool? }.values.sum / @total_shares
    end

    def share_holders
      @share_holders ||= Hash.new(0)
    end

    def player_share_holders
      share_holders.select { |s_h, _| s_h.player? }
    end

    def id
      @name
    end

    def president?(player)
      return false unless player

      owner == player
    end

    def floated?
      percent_of(self) <= 100 - @float_percent
    end

    def percent_to_float
      percent_of(self) - (100 - @float_percent)
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
      percent = share_holder.percent_of(self) + extra_percent
      %i[orange brown].include?(@share_price&.color) || percent <= @max_ownership_percent
    end

    def all_abilities
      all = @companies.flat_map(&:all_abilities)
      @abilities.each do |ability|
        abilities(ability.type) { |a| all << a }
      end
      all
    end

    def remove_ability(ability)
      return super if ability.owner == self

      @companies.each { |company| company.remove_ability(ability) }
    end

    def abilities(type, time = nil)
      abilities = []

      if (ability = super(type, time, &nil))
        abilities << ability
        yield ability, self if block_given?
      end

      @companies.each do |company|
        company.abilities(type, time) do |company_ability|
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
      @second_share.percent
    end
  end
end
