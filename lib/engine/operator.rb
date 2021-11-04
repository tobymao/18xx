# frozen_string_literal: true

require_relative 'entity'

module Engine
  module Operator
    include Entity

    attr_accessor :coordinates
    attr_reader :color, :city, :loans, :logo, :logo_filename, :simple_logo,
                :operating_history, :text_color, :tokens, :trains, :dest_icon,
                :destination_x

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
      @destination_x = opts[:destination_x]
      @dest_icon = opts[:dest_icon] ? "/icons/#{opts[:dest_icon]}" : ''
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
  end
end
