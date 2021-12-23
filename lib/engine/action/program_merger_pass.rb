# frozen_string_literal: true

require_relative 'base'
require_relative 'program_enable'

module Engine
  module Action
    class ProgramMergerPass < ProgramEnable
      attr_reader :corporations_by_round, :options

      def initialize(entity, corporations_by_round:, options:)
        super(entity)
        @corporations_by_round = corporations_by_round
        @options = options
      end

      def self.h_to_args(h, game)
        {
          corporations_by_round: h['corporations_by_round']&.transform_values do |v|
                                   v&.map do |c|
                                     game.corporation_by_id(c)
                                   end
                                 end,
          options: h['options'],
        }
      end

      def args_to_h
        {
          'corporations_by_round' => @corporations_by_round&.transform_values { |v| v.map(&:id) },
          'options' => @options,
        }
      end

      def to_s
        phases = @corporations_by_round&.map do |phase, corps|
          corps_str = corps && !corps.empty? ? corps.map(&:name).join(', ') : 'none'
          "#{phase} (#{corps_str})"
        end&.join(' and ')
        suffix = @options&.include?('disable_others') ? ', unless someone else acts' : ''
        "Pass on mergers in #{phases}#{suffix}"
      end

      def disable?(game)
        !game.round.merger?
      end
    end
  end
end
