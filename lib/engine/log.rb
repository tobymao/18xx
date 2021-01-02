# frozen_string_literal: true

module Engine
  class Log < Array
    def initialize(game)
      super()
      @game = game
    end

    def <<(message)
      super(Entry.new(message, @game.current_action_id))
    end

    class Entry
      attr_reader :message, :action

      def initialize(message, action)
        @message = message
        @action = action
      end
    end
  end
end
