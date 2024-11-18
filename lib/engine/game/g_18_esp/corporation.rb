# frozen_string_literal: true

module Engine
  module Game
    module G18ESP
      class Corporation < Engine::Corporation
        attr_reader :destination, :goals_reached_counter
        attr_accessor :destination_connected, :ran_offboard, :ran_harbor, :moved_token, :full_cap

        def initialize(game, sym:, name:, **opts)
          @game = game
          @destination = opts[:destination]
          @goals_reached_counter = 0
          super(sym: sym, name: name, **opts)
          @tokens = opts[:tokens].map do |price|
            token = Token.new(self, price: price)
            token.used = true unless price.zero?
            token
          end
          first_token = @tokens.find { |t| t.used == true }
          first_token&.used = false
        end

        def destination_connected?
          @destination_connected
        end

        def ran_offboard?
          @ran_offboard
        end

        def goal_reached!(type)
          old_reached_counter = @goals_reached_counter
          destination_goal_reached! if type == :destination
          offboard_goal_reached! if type == :offboard
          ran_harbor_reached! if type == :harbor

          return if old_reached_counter == @goals_reached_counter

          # give company extra money
          additional_capital = @par_price.price * @goals_reached_counter
          @game.bank.spend(additional_capital, self)
          # give company extra token
          blocked_token = tokens.find { |token| token.used == true && !token.hex }
          blocked_token&.used = false

          @game.log << "#{name} reached #{type} goal. " \
                       "#{name} receives #{@game.format_currency(additional_capital)} and an extra token"
        end

        def destination_goal_reached!
          return if @destination_connected

          @game.remove_dest_icon(self)
          @destination_connected = true
          @goals_reached_counter += 1
        end

        def offboard_goal_reached!
          return if @ran_offboard

          @ran_offboard = true
          @goals_reached_counter += 1
        end

        def ran_harbor_reached!
          return if @ran_harbor

          @ran_harbor = true
          @goals_reached_counter += 1
        end

        def runnable_trains
          operatable_trains(super)
        end

        def operatable_trains(trains = nil)
          trains ||= @trains
          trains = trains.dup.reject { |t| t.track_type == :narrow } if type == :minor
          trains = trains.dup.reject { |t| t.track_type == :narrow } if !@game.north_corp?(self) && !northern_token?
          trains = trains.dup.reject { |t| t.track_type == :broad } if @game.north_corp?(self) && !southern_token?
          trains
        end

        def northern_token?
          @tokens.any? { |t| t.hex && (@game.north_hex?(t.hex) ||  @game.mountain_pass_token_hex?(t.hex)) }
        end

        def southern_token?
          @tokens.any? { |t| t.hex && (!@game.north_hex?(t.hex) || @game.mountain_pass_token_hex?(t.hex)) }
        end

        def interchange?
          @interchange ||= tokens.any? { |t| t.hex && @game.valid_interchange?(t.hex.tile, self) }
        end
      end
    end
  end
end
