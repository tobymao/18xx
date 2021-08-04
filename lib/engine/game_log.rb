# frozen_string_literal: true

module Engine
  class GameLog < Array
    def initialize(game)
      super()
      @game = game
    end

    def <<(message)
      message = Entry.new(message, @game.current_action_id) unless message.is_a?(Entry)
      super(message)
    end

    class Entry
      attr_accessor :message, :action_id

      def initialize(message, action_id)
        @message = message
        @action_id = action_id
      end
    end
  end
end
