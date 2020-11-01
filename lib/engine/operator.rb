# frozen_string_literal: true

require_relative 'entity'

module Engine
  module Operator
    include Entity

    attr_accessor :rusted_self, :coordinates
    attr_reader :color, :city, :loans, :logo, :operating_history, :text_color, :tokens, :trains

    def init_operator(opts)
      @cash = 0
      @trains = []
      @operating_history = {}
      # phase rusts happen before a train actually buys, so there is a race condition
      # where buying a train rusts yourself and it looks like you must buy a train
      @rusted_self = false
      @logo = "/logos/#{opts[:logo]}.svg"
      @coordinates = opts[:coordinates]
      @city = opts[:city]
      @tokens = opts[:tokens].map { |price| Token.new(self, price: price) }
      @loans = []
      @color = opts[:color]
      @text_color = opts[:text_color] || '#ffffff'
    end

    def operator?
      true
    end

    def runnable_trains
      @trains.reject(&:operated)
    end

    # price is nil, :free, or a positive int
    def buy_train(train, price = nil)
      spend(price || train.price, train.owner) if price != :free
      train.owner.remove_train(train)
      train.owner = self
      @trains << train
      @rusted_self = false
    end

    def remove_train(train)
      @trains.delete(train)
    end

    def operated?
      @operating_history.any?
    end

    def next_token
      @tokens.find { |t| !t.used }
    end

    def find_token_by_type(type = nil)
      type ||= :normal
      @tokens.find { |t| !t.used && t.type == type }
    end

    def tokens_by_type
      @tokens.reject(&:used).uniq(&:type)
    end
  end
end
