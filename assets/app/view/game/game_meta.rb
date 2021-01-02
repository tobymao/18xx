# frozen_string_literal: true

module View
  class GameMeta < Snabberb::Component
    needs :game

    def render
      children = [h(:h3, 'Game Info')]

      if (publisher = @game.class::GAME_PUBLISHER)
        children << h(:p, [
            'Published by ',
            *Lib::Publisher.link_list(component: self, publishers: Array(publisher)),
          ])
      end
      children << h(:p, "Designed by #{@game.class::GAME_DESIGNER}") if @game.class::GAME_DESIGNER
      children << h(:p, "Implemented by #{@game.class::GAME_IMPLEMENTER}") if @game.class::GAME_IMPLEMENTER
      if @game.class::GAME_RULES_URL.is_a?(Hash)
        @game.class::GAME_RULES_URL.each do |desc, url|
          children << h(:p, [h(:a, { attrs: { href: url, target: '_blank' } }, desc)])
        end
      else
        children << h(:p, [h(:a, { attrs: { href: @game.class::GAME_RULES_URL, target: '_blank' } }, 'Rules')])
      end
      if @game.optional_rules.any?
        children << h(:h3, 'Optional Rules Used')
        @game.class::OPTIONAL_RULES.each do |o_r|
          next unless @game.optional_rules.include?(o_r[:sym])

          children << h(:p, " * #{o_r[:short_name]}: #{o_r[:desc]}")
        end
      end

      if @game.class::GAME_INFO_URL
        children << h(:p, [h(:a, { attrs: { href: @game.class::GAME_INFO_URL, target: '_blank' } }, 'More info')])
      end

      h(:div, children)
    end
  end
end
