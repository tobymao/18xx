# frozen_string_literal: true

require 'engine/action/buy_train'

module Engine
  class Phase
    attr_reader :name, :operating_rounds, :train_limit, :tiles

    TWO = {
      name: '2',
      operating_rounds: 1,
      train_limit: 4,
      tiles: :yellow,
    }.freeze

    THREE = {
      name: '3',
      operating_rounds: 2,
      train_limit: 4,
      tiles: %i[yellow green].freeze,
      on: '3',
    }.freeze

    FOUR = THREE.merge(name: '4', on: '4', train_limit: 3, events: { rust: '2' })

    FIVE = {
      name: '5',
      operating_rounds: 3,
      train_limit: 2,
      tiles: %i[yellow green brown].freeze,
      on: '5',
    }.freeze

    SIX = FIVE.merge(name: '6', on: '6', events: { rust: '3' })

    D = {
      name: 'D',
      operating_rounds: 3,
      train_limit: 2,
      tiles: %i[yellow green brown brown].freeze,
      on: 'D',
      events: { rust: '4' },
    }.freeze

    def initialize(phases, trains, log)
      @index = 0
      @phases = phases
      @trains = trains
      @log = log
      setup_phase!
    end

    def process_action(action)
      case action
      when Action::BuyTrain
        next! if action.train.name == @next_on
      end
    end

    def setup_phase!
      phase = @phases[@index]

      @name = phase[:name]
      @operating_rounds = phase[:operating_rounds]
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
      @events.each do |type, value|
        case type
        when :rust
          rust!(value)
        end
      end
    end

    def rust!(value)
      @log << "-- Event: #{value} trains rust --"

      @trains.each do |train|
        train.rust! if train.name == value
      end
    end

    def next!
      @index += 1
      setup_phase!
    end
  end
end
