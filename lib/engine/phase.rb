# frozen_string_literal: true

require_relative 'action/buy_train'

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
        train = action.train
        next! if train.name == @next_on
        rust_trains!(train, action.entity)
        @game.companies.map do |company|
          next unless company.abilities(:close_on_train_buy)

          !company.closed? && action.entity.name == company.abilities(:corporation)
          company.close!
          @log << "#{company.name} closes"
        end
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

    def rust_trains!(train, entity)
      rusted_trains = []
      @game.trains.each do |t|
        next if t.rusted || t.rusts_on != train.name

        rusted_trains << t.name
        entity.rusted_self = true if entity && entity == t.owner
        t.rust!
      end

      @log << "-- Event: #{rusted_trains.uniq.join(', ')} trains rust --" if rusted_trains.any?
    end

    def next!
      @index += 1
      setup_phase!
    end
  end
end
