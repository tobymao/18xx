# frozen_string_literal: true

require_relative 'action/buy_train'
require_relative 'action/run_routes'

module Engine
  class Phase
    attr_reader :buy_companies, :name, :operating_rounds, :train_limit, :tiles, :phases

    def initialize(phases, game)
      @index = 0
      @phases = phases
      @game = game
      @log = @game.log
      setup_phase!
    end

    def process_action(action)
      case action
      when Action::BuyTrain
        entity = action.entity
        train = action.train
        next! if train.sym == @next_on
        rust_trains!(train, entity)
        close_companies_on_train!(entity)
      when Action::RunRoutes
        rust_obsolete_trains!(action.routes)
      end
    end

    def current
      @phases[@index]
    end

    def available?(phase_name)
      return false unless phase_name

      @phases.find_index { |phase| phase[:name] == phase_name } <= @index
    end

    def setup_phase!
      phase = @phases[@index]

      @name = phase[:name]
      @operating_rounds = phase[:operating_rounds]
      @buy_companies = !!phase[:buy_companies]
      @train_limit = phase[:train_limit]
      @tiles = Array(phase[:tiles])
      @events = phase[:events] || []
      @next_on = @phases[@index + 1]&.dig(:on)
      @log << "-- Phase #{@name.capitalize} " \
        "(Operating Rounds: #{@operating_rounds}, Train Limit: #{@train_limit}, "\
        "Available Tiles: #{@tiles.map(&:capitalize).join(', ')} "\
        ') --'
      trigger_events!
    end

    def trigger_events!
      @events.each do |type, _value|
        case type
        when :close_companies
          close_companies!
        end
      end

      @game.companies.each do |company|
        next unless company.owner

        abilities = company
          .all_abilities
          .select { |a| a[:when]&.to_s == @name }

        abilities.each do |ability|
          case ability[:type]
          when :revenue_change
            company.revenue = ability[:revenue]
          end
        end
      end
    end

    def close_companies!
      @log << '-- Event: Private companies close --'

      @game.companies.each do |company|
        company.close! unless company.abilities(:never_closes)
      end
    end

    def close_companies_on_train!(entity)
      @game.companies.each do |company|
        next if company.closed?
        next unless (ability = company.abilities(:close))
        next if ability[:when] != :train
        next if entity.name != ability[:corporation].to_s

        company.close!
        @log << "#{company.name} closes"
      end
    end

    def rust_trains!(train, entity)
      obsolete_trains = []
      rusted_trains = []

      @game.trains.each do |t|
        next if t.obsolete || t.obsolete_on != train.name

        obsolete_trains << t.name
        t.obsolete = true
      end

      @game.trains.each do |t|
        next if t.rusted || t.rusts_on != train.name

        rusted_trains << t.name
        entity.rusted_self = true if entity && entity == t.owner
        t.rust!
      end

      @log << "-- Event: #{obsolete_trains.uniq.join(', ')} trains are obsolete --" if obsolete_trains.any?
      @log << "-- Event: #{rusted_trains.uniq.join(', ')} trains rust --" if rusted_trains.any?
    end

    def rust_obsolete_trains!(routes)
      rusted_trains = []

      routes.each do |route|
        train = route.train
        next unless train.obsolete

        rusted_trains << train.name
        train.rust!
      end

      @log << '-- Event: Obsolete trains rust --' if rusted_trains.any?
    end

    def next!
      @index += 1
      setup_phase!
    end
  end
end
