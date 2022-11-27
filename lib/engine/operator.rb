# frozen_string_literal: true

require_relative 'entity'

module Engine
  module Operator
    include Entity

    attr_accessor :coordinates, :color, :text_color
    attr_reader :city, :loans, :logo, :logo_filename, :simple_logo,
                :operating_history, :tokens, :trains, :destination_icon,
                :destination_coordinates

    def init_operator(opts)
      @cash = 0
      @trains = []
      @operating_history = {}
      @logo_filename = "#{opts[:logo]}.svg"
      @logo = "/logos/#{@logo_filename}"
      @simple_logo = opts[:simple_logo] ? "/logos/#{opts[:simple_logo]}.svg" : @logo
      @coordinates = opts[:coordinates]
      @city = opts[:city]
      @tokens = opts[:tokens].map { |price| Token.new(self, price: price) }
      @loans = []
      @color = opts[:color]
      @text_color = opts[:text_color] || '#ffffff'
      @destination_coordinates = opts[:destination_coordinates]
      @destination_icon = opts[:destination_icon] ? "/icons/#{opts[:destination_icon]}" : ''
      @token_book_value_override = opts[:token_book_value_override]
    end

    def operator?
      true
    end

    def runnable_trains
      @trains.reject(&:operated)
    end

    def operated?
      !@operating_history.empty?
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

    def unplaced_tokens
      @tokens.reject(&:city)
    end

    def placed_tokens
      @tokens.select(&:city)
    end

    def book_value
      trains = @trains.sum(&:price)
      tokens = @tokens.filter(&:used).sum { |t| @token_book_value_override || t.price }
      loans = @loans.sum(&:amount)
      trains + tokens + @cash - loans
    end
  end
end
