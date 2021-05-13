# frozen_string_literal: true

module Engine
  module Game
    module Meta
      # platform-relevant metadata
      DEV_STAGES = %i[production beta alpha prealpha].freeze
      DEV_STAGE = :prealpha
      PROTOTYPE = false
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
      GAME_SUPERTITLE = nil
      GAME_FULL_TITLE = nil
      GAME_ALIASES = [].freeze
      GAME_VARIANTS = [].freeze
      GAME_IS_VARIANT_OF = nil
      GAME_DROPDOWN_TITLE = nil

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
              part = (%w[Game Meta].include?(last) ? parts[-2] : last)
              part.slice(1..-1)
            end
        end

        def full_title
          @full_title ||=
            self::GAME_FULL_TITLE ||
            [self::GAME_SUPERTITLE, title, self::GAME_SUBTITLE].compact.join(': ')
        end

        def fs_name
          @fs_name ||=
            begin
              parts = name.split('::')
              last = parts.last
              part = (%w[Game Meta].include?(last) ? parts[-2] : last)
              part.sub(/^G/, 'g_').gsub(/(.)([A-Z]+)/, '\1_\2').downcase
            end
        end

        def meta
          self
        end

        def game_instance?
          false
        end

        def game_variants
          @game_variants ||= self::GAME_VARIANTS.map do |v|
            [v[:sym], v.merge({ meta: Engine.meta_by_title(v[:title]) })]
          end.to_h
        end
      end
    end
  end
end
