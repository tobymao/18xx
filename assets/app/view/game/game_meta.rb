# frozen_string_literal: true

module View
  module Game
    class GameMeta < Snabberb::Component
      needs :game

      def render
        children = [h(:h3, 'Game Info')]

        children.concat(render_publisher)
        children.concat(render_designer)
        children.concat(render_implementer)
        children.concat(render_rule_links)
        children.concat(render_optional_rules)
        children.concat(render_more_info)

        h(:div, children)
      end

      def render_publisher
        return [] unless @game.class::GAME_PUBLISHER

        [h(:p, [
          'Published by ',
          *Lib::Publisher.link_list(component: self, publishers: Array(@game.class::GAME_PUBLISHER)),
        ])]
      end

      def render_designer
        return [] unless @game.class::GAME_DESIGNER

        [h(:p, "Designed by #{@game.class::GAME_DESIGNER}")]
      end

      def render_implementer
        return [] unless @game.class::GAME_IMPLEMENTER

        [h(:p, "Implemented by #{@game.class::GAME_IMPLEMENTER}")]
      end

      def render_rule_links
        unless @game.class::GAME_RULES_URL.is_a?(Hash)
          return [h(:p, [h(:a, { attrs: { href: @game.class::GAME_RULES_URL, target: '_blank' } }, 'Rules')])]
        end

        @game.class::GAME_RULES_URL.map do |desc, url|
          h(:p, [h(:a, { attrs: { href: url, target: '_blank' } }, desc)])
        end
      end

      def render_optional_rules
        return [] if @game.optional_rules.empty?

        used_optional_rules = @game.class::OPTIONAL_RULES.map do |o_r|
          next unless @game.optional_rules.include?(o_r[:sym])

          h(:p, " * #{o_r[:short_name]}: #{o_r[:desc]}")
        end.compact
        return [] if used_optional_rules.empty?

        [h(:h3, 'Optional Rules Used'), *used_optional_rules]
      end

      def render_more_info
        return [] unless @game.class::GAME_INFO_URL

        [h(:p, [h(:a, { attrs: { href: @game.class::GAME_INFO_URL, target: '_blank' } }, 'More info')])]
      end
    end
  end
end
