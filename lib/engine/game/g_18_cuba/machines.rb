# frozen_string_literal: true

module Engine
  module Game
    module G18Cuba
      module Machines
        MACHINES = {
          yellow: { bonus: 10, prices: [25, 30, 35, 40, 40, 40, 40, 40, 40, 40] },
          green: { bonus: 20, status: 'green_machines', prices: [45, 50, 55, 60, 60, 60, 60, 60] },
          brown: { bonus: 40, status: 'brown_machines', prices: [65, 70, 75, 80] },
        }.freeze
        MACHINE_LIMIT = 3

        def machines_setup
          @machines = {}
          @machine_charter = self.class::MACHINES.transform_values { |machine| machine[:prices].dup }
        end

        def machines(corporation)
          @machines.fetch(corporation, [])
        end

        def machine_bonus(generation)
          self.class::MACHINES[generation][:bonus]
        end

        def machine_price(generation)
          @machine_charter[generation].first
        end

        def buyable_machine_generations(corporation)
          return [] if corporation.type != :minor
          return [] if machines(corporation).size >= self.class::MACHINE_LIMIT

          self.class::MACHINES.keys.select do |generation|
            status = self.class::MACHINES[generation][:status]
            (!status || @phase.status.include?(status)) &&
              !@machine_charter[generation].empty? &&
              corporation.cash >= machine_price(generation)
          end
        end

        def buy_machine!(corporation, generation)
          price = @machine_charter[generation].shift
          corporation.spend(price, @bank)
          (@machines[corporation] ||= []) << generation
          @log << "#{corporation.name} buys a #{generation} machine "\
                  "(+#{format_currency(machine_bonus(generation))}) for #{format_currency(price)}"
        end

        def status_str(corporation)
          return if machines(corporation).empty?

          "Machines: #{machines(corporation).join(', ')}"
        end
      end
    end
  end
end
