# frozen_string_literal: true

require 'lib/settings'
require 'lib/text'
require 'view/game/companies'

module View
  module Game
    class Player < Snabberb::Component
      include Lib::Settings
      include Lib::Text

      needs :player
      needs :game
      needs :user, default: nil, store: true
      needs :display, default: 'inline-block'
      needs :show_hidden, default: false
      needs :hide_logo, store: true, default: false

      def render
        card_style = {
          border: @game.round.can_act?(@player) ? '4px solid' : '1px solid gainsboro',
          paddingBottom: '0.2rem',
        }
        card_style[:display] = @display

        divs = [
          render_title,
          render_body,
        ]

        if @player.companies.any? || @show_hidden
          divs << h(Companies, owner: @player, game: @game, show_hidden: @show_hidden)
        end

        unless (minors = @game.player_card_minors(@player)).empty?
          divs << render_minors(minors)
        end

        h('div.player.card', { style: card_style }, divs)
      end

      def render_title
        props = {
          style: {
            padding: '0.4rem',
            backgroundColor: color_for(:bg2),
            color: color_for(:font2),
          },
        }

        h('div.player.title.nowrap', props, @player.name)
      end

      def render_body
        props = {
          style: {
            margin: '0.2rem',
            display: 'grid',
            grid: '1fr / auto-flow',
            justifyItems: 'center',
            alignItems: 'start',
          },
        }

        divs = [
          render_info,
        ]

        divs << render_shares if @player.shares.any?

        h(:div, props, divs)
      end

      def render_info
        num_certs = @game.num_certs(@player)
        cert_limit = @game.cert_limit

        td_cert_props = {
          style: {
            color: num_certs > cert_limit ? 'red' : 'currentColor',
          },
        }

        trs = [
          h(:tr, [
            h(:td, 'Cash'),
            h('td.right', @game.format_currency(@player.cash)),
          ]),
        ]

        if @game.active_step&.current_actions&.include?('bid')
          committed = @game.active_step.committed_cash(@player, @show_hidden)
          trs.concat([
            h(:tr, [
              h(:td, 'Committed'),
              h('td.right', @game.format_currency(committed)),
            ]),
            h(:tr, [
              h(:td, 'Available'),
              h('td.right', @game.format_currency(@player.cash - committed)),
            ]),
          ]) if committed.positive?

          trs.concat([
             h(:tr, [
               h(:td, 'Bid tokens'),
               h('td.right', "#{@game.active_step.bidding_tokens(@player)} / #{@game.bidding_token_per_player}"),
             ]),
           ]) if @game.active_step.respond_to?(:bidding_tokens)
        end

        trs.concat([
          h(:tr, [
            h(:td, 'Value'),
            h('td.right', @game.format_currency(@game.player_value(@player))),
          ]),
          h(:tr, [
            h(:td, 'Liquidity'),
            h('td.right', @game.format_currency(@game.liquidity(@player))),
          ]),
        ])

        if @game.respond_to?(:player_debt)
          trs << h(:tr, [
            h(:td, 'Loan'),
            h('td.right', @game.format_currency(@game.player_debt(@player))),
          ]) if @game.player_debt(@player).positive?
        end

        if @game.respond_to?(:player_interest)
          trs << h(:tr, [
            h(:td, 'Interest'),
            h('td.right', @game.format_currency(@game.player_interest(@player))),
          ]) if @game.player_interest(@player).positive?
        end

        if @game.respond_to?(:bidding_power)
          trs << h(:tr, [
            h(:td, 'Bid Power'),
            h('td.right', @game.format_currency(@game.bidding_power(@player))),
          ])
        end
        trs << h(:tr, [
          h(:td, 'Certs'),
          h('td.right', td_cert_props, @game.show_game_cert_limit? ? "#{num_certs}/#{cert_limit}" : num_certs.to_s),
        ])

        priority_props = {
          attrs: { colspan: '2' },
          style: {
            background: 'salmon',
            color: 'black',
            borderRadius: '3px',
          },
        }

        order = @game.next_sr_player_order
        trs << render_priority_deal(priority_props) if order == :after_last_to_act &&
                                                       @player == @game.priority_deal_player
        trs << render_next_sr_position(priority_props) if order == :first_to_pass &&
                                                          @game.next_sr_position(@player)

        h(:table, trs)
      end

      def render_priority_deal(priority_props)
        h(:tr, [
          h('td.center.italic', priority_props, 'Priority Deal'),
        ])
      end

      def render_next_sr_position(priority_props)
        position = @game.next_sr_position(@player) + 1

        h(:tr, [
          h(:td, 'Next SR'),
          h('td.right', position == 1 ? priority_props : nil, ordinal(position)),
        ])
      end

      def render_shares
        shares = @player
          .shares_by_corporation.reject { |_, s| s.empty? }
          .sort_by { |c, s| [s.sum(&:percent), c.president?(@player) ? 1 : 0, c.name] }
          .reverse
          .map { |c, s| render_corporation_shares(c, s) }

        h(:table, shares)
      end

      def render_corporation_shares(corporation, shares)
        td_props = {
          style: {
            padding: '0 0.2rem',
          },
        }
        div_props = {
          style: {
            height: '20px',
          },
        }
        logo_props = {
          attrs: {
            src: setting_for(:simple_logos, @game) ? corporation.simple_logo : corporation.logo,
          },
          style: {
            height: '20px',
          },
        }

        children = []
        children << h('td.center', td_props, [h(:div, div_props, [h(:img, logo_props)])]) unless @hide_logo

        president_marker = corporation.president?(@player) ? '*' : ''
        children << h(:td, td_props, corporation.name + president_marker)
        children << h('td.right', td_props, "#{shares.sum(&:percent)}%")
        h('tr.row', children)
      end

      def render_minors(minors)
        minor_logos = minors.map do |minor|
          logo_props = {
            attrs: {
              src: minor.logo,
            },
            style: {
              paddingRight: '1px',
              paddingLeft: '1px',
              height: '20px',
            },
          }
          h(:img, logo_props)
        end
        inner_props = {
          style: {
            display: 'inline-block',
          },
        }
        outer_props = {
          style: {
            textAlign: 'center',
          },
        }
        h('div', outer_props, [h('div', inner_props, minor_logos)])
      end
    end
  end
end
