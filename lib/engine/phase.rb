# frozen_string_literal: true

require_relative 'action/buy_train'

module Engine
  class Phase
    attr_reader :buy_companies, :name, :operating_rounds, :train_limit, :tiles

    TWO = {
      name: '2',
      operating_rounds: 1,
      train_limit: 4,
      no_buy_in: true,
      tiles: :yellow,
    }.freeze

    THREE = {
      name: '3',
      operating_rounds: 2,
      train_limit: 4,
      tiles: %i[yellow green].freeze,
      on: '3',
    }.freeze

    FOUR = THREE.merge(name: '4', on: '4', train_limit: 3)

    FIVE = {
      name: '5',
      operating_rounds: 3,
      train_limit: 2,
      tiles: %i[yellow green brown].freeze,
      on: '5',
      events: { close_companies: true },
    }.freeze

    SIX = FIVE.merge(name: '6', on: '6', events: nil)

    D = {
      name: 'D',
      operating_rounds: 3,
      train_limit: 2,
      tiles: %i[yellow green brown].freeze,
      on: 'D',
    }.freeze

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
        next! if action.train.name == @next_on
      end
    end

    def available?(phase_name)
      return false unless phase_name

      @phases.find_index { |phase| phase[:name] == phase_name } <= @index
    end

    def setup_phase!
      phase = @phases[@index]

      @name = phase[:name]
      @operating_rounds = phase[:operating_rounds]
      @buy_companies = !phase[:no_buy_in]
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
          .select { |a| a[:when] == @name }

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

    def next!
      @index += 1
      setup_phase!
    end
  end
end
