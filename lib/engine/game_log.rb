# frozen_string_literal: true

module Engine
  class GameLog < Array
    attr_writer :indent_group

    def initialize(game)
      super()
      @game = game
      @indent_group = nil
    end

    def <<(message)
      entry = message.is_a?(Entry) ? message : Entry.new(message, @game.current_action_id)
      begin
        step = @game.round&.steps&.find { |s| s.respond_to?(:auctioning_lot) && s.auctioning_lot }
        entry.indent_group = if step
                               step.auctioning_lot.id.to_s
                             else
                               @indent_group
                             end
      rescue StandardError
        # may raise during game initialization before a round exists
      end
      super(entry)
    end

    class Entry
      attr_accessor :message, :action_id, :indent_group

      def initialize(message, action_id)
        @message = message
        @action_id = action_id
      end
    end
  end
end
