# frozen_string_literal: true

module Engine
  module Game
    module Meta
      # platform-relevant metadata
      DEV_STAGES = %i[production beta alpha prealpha].freeze
      DEV_STAGE = :prealpha
      PROTOTYPE = false
      DEPENDS_ON = nil
      AUTOROUTE = true

      # game title variations
      GAME_TITLE = nil # canonical title stored in database, defaults to '18xx' part of 'G18xx' module name
      GAME_DISPLAY_TITLE = nil # defaults to GAME_TITLE; used in UI on game cards, new game dropdown, game page
      GAME_SUBTITLE = nil
      GAME_FULL_TITLE = nil # defaults to "GAME_DISPLAY_TITLE", then "GAME_TITLE: GAME_SUBTITLE"; used in "Game Info" section
      GAME_DROPDOWN_TITLE = nil # new game dropdown, defaults to GAME_DISPLAY_TITLE + location and dev stage if applicable
      GAME_ISSUE_LABEL = nil # the GitHub label used to organize issues for this title, defaults to GAME_TITLE

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

      # terms to match with on the create games page; see keywords function for
      # values automatically considered as keywords
      KEYWORDS = [].freeze

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

        def label
          @label ||=
            begin
              label = self::GAME_ISSUE_LABEL || title
              label = %("#{label}") if label.include?(' ')
              label
            end
        end

        def known_issues_url
          "https://github.com/tobymao/18xx/issues?q=is%3Aissue+is%3Aopen+label%3A#{label}"
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

        def keywords
          @keywords ||= [
            *self::KEYWORDS,
            title,
            full_title,
            display_title,
            *self::GAME_ALIASES,
            self::DEPENDS_ON,
            self::GAME_LOCATION,
            *self::GAME_VARIANTS.map { |v| v[:title] },
            *self::OPTIONAL_RULES.map { |o_r| o_r[:short_name] },
            self::DEV_STAGE.to_s,
            self::PROTOTYPE ? 'PROTOTYPE' : nil,
            self::GAME_DESIGNER,
            *Array(self::GAME_PUBLISHER).map { |pub| (Engine::Publisher::INFO[pub] || { name: pub })[:name] },
            self::GAME_IMPLEMENTER,
          ].compact.flat_map { |c| c.upcase.split(/[:, ]+/) }.uniq
        end
      end
    end
  end
end
