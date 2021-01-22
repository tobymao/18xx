# frozen_string_literal: true

require_relative 'action/buy_train'

module Engine
  class Phase
    attr_accessor :next_on
    attr_reader :name, :operating_rounds, :tiles, :phases, :status, :corporation_sizes

    def initialize(phases, game)
      @index = 0
      @phases = phases
      @game = game
      @depot = @game.depot
      @log = @game.log
      setup_phase!
    end

    def buying_train!(entity, train)
      next! while @next_on.include?(train.sym)

      train.events.each do |event|
        @game.send("event_#{event['type']}!")
      end
      train.events.clear

      @game.rust_trains!(train, entity)
      close_companies_on_train!(entity)
      @depot.depot_trains(clear: true)
    end

    def current
      @phases[@index]
    end

    def upcoming
      @phases[@index + 1]
    end

    def train_limit(entity)
      limit = train_limit_constant(entity)
      return limit if limit.positive?

      limit =
        if @train_limit.is_a?(Hash)
          @train_limit[entity.type] || 0
        else
          @train_limit
        end
      limit + train_limit_increase(entity)
    end

    def available?(phase_name)
      return false unless phase_name

      @phases.find_index { |phase| phase[:name] == phase_name } <= @index
    end

    def setup_phase!
      phase = @phases[@index]

      @name = phase[:name]
      @operating_rounds = phase[:operating_rounds]
      @train_limit = phase[:train_limit]
      @tiles = Array(phase[:tiles])
      @events = phase[:events] || []
      @status = phase[:status] || []
      @corporation_sizes = phase[:corporation_sizes]
      @next_on = Array(@phases[@index + 1]&.dig(:on))

      log_msg =  "-- Phase #{@name} ("
      log_msg += "Operating Rounds: #{@operating_rounds} | " if @operating_rounds
      log_msg += "Train Limit: #{train_limit_to_s(@train_limit)}"
      log_msg += " | Available Tiles: #{@tiles.map(&:capitalize).join(', ')}"
      log_msg += ') --'
      @log << log_msg
      trigger_events!
    end

    def trigger_events!
      @game.companies.each do |company|
        next unless company.owner

        @game.abilities(company, :revenue_change, on_phase: @name) do |ability|
          company.revenue = ability.revenue
        end

        @game.abilities(company, :close, on_phase: @name) do
          @log << "Company #{company.name} closes"
          company.close!
        end
      end

      (@game.companies + @game.corporations).each { |c| c.remove_ability_when(@name) }
    end

    def close_companies_on_train!(entity)
      @game.companies.each do |company|
        next if company.closed?

        @game.abilities(company, :close, time: 'bought_train') do |ability|
          next if entity&.name != ability.corporation

          company.close!
          @log << "#{company.name} closes"
        end
      end
    end

    def next!
      @index += 1
      setup_phase!
    end

    def train_limit_to_s(train_limit)
      return train_limit unless train_limit.is_a?(Hash)

      train_limit.map { |type, limit| "#{type} => #{limit}" }.join(',')
    end

    private

    def train_limit_increase(entity)
      Array(@game.abilities(entity, :train_limit)).sum(&:increase)
    end

    def train_limit_constant(entity)
      @game.abilities(entity, :train_limit) { |ability| return ability.constant if ability.constant }
      0
    end
  end
end
