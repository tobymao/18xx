# frozen_string_literal: true

module Engine
  module Game
    module Meta
      # platform-relevant metadata
      DEV_STAGES = %i[production beta alpha prealpha].freeze
      DEV_STAGE = :prealpha
      DEPENDS_ON = nil

      # real game metadata
      GAME_DESIGNER = nil
      GAME_IMPLEMENTER = nil
      GAME_INFO_URL = nil
      GAME_LOCATION = nil
      GAME_PUBLISHER = nil
      GAME_RULES_URL = nil
      GAME_TITLE = nil
      GAME_SUBTITLE = nil
      GAME_ALIASES = [].freeze

      # rules data that needs to be known to the engine without loading in the
      # full game class
      PLAYER_RANGE = nil
      OPTIONAL_RULES = [].freeze

      def self.included(klass)
        klass.extend(ClassMethods)
      end

      module ClassMethods
        # sort games by display title, whether it is the Game class or Meta module
        def <=>(other)
          [DEV_STAGES.index(self::DEV_STAGE), title.sub(/18\s+/, '18').downcase] <=>
            [DEV_STAGES.index(other::DEV_STAGE), other.title.sub(/18\s+/, '18').downcase]
        end

        def title
          @title ||=
            self::GAME_TITLE ||
            begin
              parts = name.split('::')
              last = parts.last
              part = (last == 'Game' || last == 'Meta' ? parts[-2] : last)
              part.slice(1..-1)
            end
        end

        def fs_name
          @fs_name ||=
            begin
              parts = name.split('::')
              last = parts.last
              part = (last == 'Game' || last == 'Meta' ? parts[-2] : last)
              part.sub(/^G/, 'g_').gsub(/(.)([A-Z]+)/, '\1_\2').downcase
            end
        end
      end
    end
  end
end
