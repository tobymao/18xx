# frozen_string_literal: true

module Engine
  module Game
    module Meta
      # platform-relevant metadata
      DEV_STAGES = %i[production beta alpha prealpha].freeze
      DEV_STAGE = :prealpha
      PROTOTYPE = false
      DEPENDS_ON = nil

      # game title variations
      GAME_TITLE = nil # canonical title stored in database, defaults to '18xx' part of 'G18xx' module name
      GAME_DISPLAY_TITLE = nil # defaults to GAME_TITLE; used in UI on game cards, new game dropdown, game page
      GAME_SUBTITLE = nil
      GAME_FULL_TITLE = nil # defaults to "GAME_DISPLAY_TITLE", then "GAME_TITLE: GAME_SUBTITLE"; used in "Game Info" section
      GAME_DROPDOWN_TITLE = nil # new game dropdown, defaults to GAME_DISPLAY_TITLE + location and dev stage if applicable

      # real game metadata
      GAME_DESIGNER = nil
      GAME_IMPLEMENTER = nil
      GAME_INFO_URL = nil
      GAME_LOCATION = nil
      GAME_PUBLISHER = nil
      GAME_RULES_URL = nil
      GAME_ALIASES = [].freeze
      GAME_VARIANTS = [].freeze
      GAME_IS_VARIANT_OF = nil

      # rules data that needs to be known to the engine without loading in the
      # full game class
      PLAYER_RANGE = nil
      OPTIONAL_RULES = [].freeze
      MUTEX_RULES = [].freeze

      def self.included(klass)
        klass.extend(ClassMethods)
      end

      module ClassMethods
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

        def display_title
          @display_title ||= (self::GAME_DISPLAY_TITLE || title)
        end

        def full_title
          @full_title ||=
            self::GAME_FULL_TITLE ||
            self::GAME_DISPLAY_TITLE ||
            [title, self::GAME_SUBTITLE].compact.join(': ')
        end

        def fs_name
          @fs_name ||=
            begin
              parts = name.split('::')
              last = parts.last
              part = (%w[Game Meta].include?(last) ? parts[-2] : last)
              part.sub(/^G/, 'g_').gsub(/(.)([A-Z]+)/, '\1_\2').sub(/__/, '_').downcase
            end
        end

        def meta
          self
        end

        def game_instance?
          false
        end

        def game_variants
          @game_variants ||= self::GAME_VARIANTS.to_h do |v|
            [v[:sym], v.merge({ meta: Engine.meta_by_title(v[:title]) })]
          end
        end
      end
    end
  end
end
