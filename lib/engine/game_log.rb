# frozen_string_literal: true

module Engine
  class GameLog < Array
    def initialize(game)
      super()
      @game = game
    end

    def <<(message)
      entry = message.is_a?(Entry) ? message : Entry.new(message, @game.current_action_id)
      begin
        step = @game.active_step
        entry.auctioning_lot = step.auctioning_lot if step.respond_to?(:auctioning_lot)
      rescue StandardError
        # active_step may raise during game initialization before a round exists
      end
      super(entry)
    end

    class Entry
      attr_accessor :message, :action_id, :auctioning_lot

      def initialize(message, action_id)
        @message = message
        @action_id = action_id
      end
    end
  end
end
