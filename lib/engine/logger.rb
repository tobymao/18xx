# frozen_string_literal: true

module Engine
  class Logger
    attr_reader :lines

    def initialize(game, lines = [])
      @game = game
      @lines = lines
      @last_action_id = 0
    end

    def message!(action)
      @lines << { type: :undo } if @last_action_id + 1 < action.id
      @last_action_id = action.id

      @lines << {
        type: :message,
        id: action.id,
        created_at: action.created_at,
        username: action.entity&.name,
        message: action.message,
      }
    end

    def action!(message)
      acted!(nil, message)
    end

    def acted!(entity, message)
      return @lines << message unless (action = @game&.current_action)

      entity ||= action.entity
      player = entity.owner unless entity.player?

      return @lines << "#{entity.name} #{message}" if @last_action_id == action.id

      @lines << { type: :undo } if @last_action_id + 1 < action.id
      @last_action_id = action.id

      @lines << {
        type: :action,
        id: action.id,
        created_at: action.created_at,
        entity: entity&.name,
        player: player&.name,
        user: (@game.player_by_id(action.user)&.name || 'Owner' if action.user),
        message: message,
      }
    end

    def queue!
      old_size = @lines.size
      yield
      @queued_log = @lines.pop(@lines.size - old_size)
    end

    def flush!
      @queued_log.each { |l| @lines << l }
      @queued_log = []
    end

    def <<(entry)
      @lines << entry
    end
  end
end
