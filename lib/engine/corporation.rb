# frozen_string_literal: true

require_relative 'ownable'
require_relative 'passer'
require_relative 'share'
require_relative 'share_holder'
require_relative 'spender'
require_relative 'token'

module Engine
  class Corporation
    include Ownable
    include Passer
    include ShareHolder
    include Spender

    attr_accessor :ipoed, :rusted_self, :share_price, :tokens
    attr_reader :capitalization, :color, :companies, :coordinates, :min_price, :name, :full_name,
                :logo, :text_color, :trains, :operating_history
    attr_writer :par_price

    def initialize(sym:, name:, tokens:, **opts)
      @name = sym
      @full_name = name
      @logo = "/logos/#{opts[:logo]}.svg"
      @tokens = tokens.map { |price| Token.new(self, price: price) }
      [
        Share.new(self, president: true, percent: 20),
        *8.times.map { |index| Share.new(self, percent: 10, index: index + 1) },
      ].each { |share| shares_by_corporation[self] << share }

      @share_price = nil
      @par_price = nil
      @ipoed = false
      # phase rusts happen before a train actually buys, so there is a race condition
      # where buying a train rusts yourself and it looks like you must buy a train
      @rusted_self = false
      @trains = []
      @companies = []
      @operating_history = {}

      @cash = 0
      @capitalization = opts[:capitalization] || :full
      @float_percent = opts[:float_percent] || 60
      @coordinates = opts[:coordinates]
      @min_price = opts[:min_price]
      @color = opts[:color]
      @text_color = opts[:text_color] || '#ffffff'
      @always_market_price = opts[:always_market_price] || false
      @needs_token_to_par = opts[:needs_token_to_par] || false
    end

    def <=>(other)
      # corporation with higher share price, farthest on the right, and first position on the share price goes first
      sp = share_price
      ops = other.share_price
      [ops.price, ops.coordinates&.last, -ops.corporations.find_index(other)] <=>
      [sp.price, sp.coordinates.last, -sp.corporations.find_index(self)]
    end

    def counts_for_limit
      # if no share price, like when you exchange a share pre-ipo
      # it still counts
      @share_price ? @share_price.counts_for_limit : true
    end

    def can_par?
      return false if @needs_token_to_par && @tokens.empty?

      true
    end

    def par_price
      @always_market_price ? @share_price : @par_price
    end

    def num_ipo_shares
      num_shares_of(self)
    end

    def num_player_shares
      share_holders.values.sum / 10
    end

    def num_market_shares
      10 - num_ipo_shares - num_player_shares
    end

    def next_token
      @tokens.find { |t| !t.used? }
    end

    def share_holders
      @share_holders ||= Hash.new(0)
    end

    def id
      @name
    end

    def buy_train(train, price = nil)
      spend(price || train.price, train.owner)
      train.owner.remove_train(train)
      train.owner = self
      @trains << train
      @rusted_self = false
    end

    def remove_train(train)
      @trains.delete(train)
    end

    def president?(player)
      return false unless player

      owner == player
    end

    def floated?
      percent_of(self) <= 100 - @float_percent
    end

    def player?
      false
    end

    def company?
      false
    end

    def corporation?
      true
    end

    def operated?
      @operating_history.any?
    end

    def inspect
      "<#{self.class.name}: #{id}>"
    end

    # Is it legal to hold percent shares in this corporation?
    def holding_ok?(share_holder, extra_percent = 0)
      percent = share_holder.percent_of(self) + extra_percent
      %i[orange brown].include?(@share_price&.color) || percent <= 60
    end

    def abilities(type)
      @companies.each do |company|
        ability = company.abilities(type)
        yield ability, company if ability
      end
    end
  end
end
