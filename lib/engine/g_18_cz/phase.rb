# frozen_string_literal: true

require_relative '../phase'

module Engine
  module G18CZ
    class Phase < Phase
      def rust_trains!(train, entity)
        rusted_trains = []
        owners = Hash.new(0)

        @game.trains.each do |t|
          next if t.rusted

          # entity is nil when a train is exported. Then all trains are rusting
          train_symbol_to_compare = entity.nil? ? train.sym : train.name
          should_rust = t.rusts_on == train_symbol_to_compare
          next unless should_rust
          next unless @game.rust?(t)

          rusted_trains << t.name
          owners[t.owner.name] += 1
          entity.rusted_self = true if entity && entity == t.owner
          @game.rust(t)
        end

        @log << "-- Event: #{rusted_trains.uniq.join(', ')} trains rust " \
          "( #{owners.map { |c, t| "#{c} x#{t}" }.join(', ')}) --" if rusted_trains.any?
      end
    end
  end
end
