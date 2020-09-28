# frozen_string_literal: true

require_relative 'action/buy_train'

module Engine
  class Phase
    attr_reader :name, :operating_rounds, :tiles, :phases, :status

    def initialize(phases, game)
      @index = 0
      @phases = phases
      @game = game
      @depot = @game.depot
      @log = @game.log
      setup_phase!
    end

    def buying_train!(entity, train)
      next! if train.sym == @next_on

      train.events.each do |event|
        @game.send("event_#{event['type']}!")
      end
      train.events.clear

      rust_trains!(train, entity)
      close_companies_on_train!(entity)
    end

    def current
      @phases[@index]
    end

    def train_limit(entity)
      @train_limit + train_limit_increase(entity)
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
      @next_on = @phases[@index + 1]&.dig(:on)

      @log << "-- Phase #{@name} " \
        "(Operating Rounds: #{@operating_rounds}, Train Limit: #{@train_limit}, "\
        "Available Tiles: #{@tiles.map(&:capitalize).join(', ')} "\
        ') --'
      trigger_events!
    end

    def trigger_events!
      @game.companies.each do |company|
        next unless company.owner

        company.abilities(:revenue_change, @name) do |ability|
          company.revenue = ability.revenue
        end

        company.abilities(:close, @name) do
          @log << "Company #{company.name} closes"
          company.close!
        end
      end

      (@game.companies + @game.corporations).each { |c| c.remove_ability_when(@name) }
    end

    def close_companies_on_train!(entity)
      @game.companies.each do |company|
        next if company.closed?

        company.abilities(:close, :train) do |ability|
          next if entity&.name != ability.corporation

          company.close!
          @log << "#{company.name} closes"
        end
      end
    end

    def rust_trains!(train, entity)
      obsolete_trains = []
      rusted_trains = []
      owners = Hash.new(0)

      @game.trains.each do |t|
        next if t.obsolete || t.obsolete_on != train.sym

        obsolete_trains << t.name
        t.obsolete = true
      end

      @game.trains.each do |t|
        next if t.rusted

        should_rust = t.rusts_on == train.sym || (t.obsolete_on == train.sym && @depot.discarded.include?(t))
        next unless should_rust

        rusted_trains << t.name
        owners[t.owner.name] += 1
        entity.rusted_self = true if entity && entity == t.owner
        t.rust!
      end

      @log << "-- Event: #{obsolete_trains.uniq.join(', ')} trains are obsolete --" if obsolete_trains.any?
      @log << "-- Event: #{rusted_trains.uniq.join(', ')} trains rust " \
        "( #{owners.map { |c, t| "#{c} x#{t}" }.join(', ')}) --" if rusted_trains.any?
    end

    def next!
      @index += 1
      setup_phase!
    end

    private

    def train_limit_increase(entity)
      entity.abilities(:train_limit) { |ability| return ability.increase }
      0
    end
  end
end
