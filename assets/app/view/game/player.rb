# frozen_string_literal: true

require 'lib/settings'
require 'lib/text'
require 'lib/profile_link'
require 'view/game/companies'
require 'view/game/unsold_companies'
require 'view/share_calculation'

module View
  module Game
    class Player < Snabberb::Component
      include Lib::Settings
      include Lib::Text
      include Lib::ProfileLink
      include View::ShareCalculation

      needs :player
      needs :game
      needs :user, default: nil, store: true
      needs :display, default: 'inline-block'
      needs :show_hidden, default: false
      needs :hide_logo, store: true, default: false
      needs :show_companies, default: true

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

        if @show_companies
          divs << h(Companies, owner: @player, game: @game, show_hidden: @show_hidden) if @player.companies.any? || @show_hidden
          divs << h(UnsoldCompanies, owner: @player, game: @game) unless @player.unsold_companies.empty?
        end

        unless (minors = @game.player_card_minors(@player)).empty?
          divs << render_minors(minors)
        end

        h('div.player.card', { style: card_style }, divs)
      end

      def render_title
        bg_color = setting_for(:show_player_colors, @game) && player_colors(@game.players)[@player]
        bg_color ||= color_for(:bg2)

        props = {
          style: {
            padding: '0.4rem',
            backgroundColor: bg_color,
            color: contrast_on(bg_color),
          },
        }

        h('div.player.title.nowrap', props, [profile_link(@player.id, @player.name)])
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
        cert_limit = @game.cert_limit(@player)

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
          if committed.positive?
            trs.concat([
              h(:tr, [
                h(:td, 'Committed'),
                h('td.right', @game.format_currency(committed)),
              ]),
              h(:tr, [
                h(:td, 'Available'),
                h('td.right', @game.format_currency(@player.cash - committed)),
              ]),
            ])
          end

          if @game.active_step.respond_to?(:bidding_tokens)
            trs.concat([
              h(:tr, [
                h(:td, 'Bid tokens'),
                h('td.right', "#{@game.active_step.bidding_tokens(@player)} / #{@game.bidding_token_per_player}"),
              ]),
            ])
          end
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

        if @game.respond_to?(:player_debt) && @game.player_debt(@player).positive?
          trs << h(:tr, [
            h(:td, 'Loan'),
            h('td.right', @game.format_currency(@game.player_debt(@player))),
          ])
        end

        if @game.respond_to?(:player_loans)
          trs << h(:tr, [
            h(:td, 'Loans'),
            h('td.right', td_cert_props, "#{@game.player_loans(@player)}/#{@game.max_player_loans}"),
          ])
        end

        if @game.respond_to?(:player_interest) && @game.player_interest(@player).positive?
          trs << h(:tr, [
            h(:td, 'Interest'),
            h('td.right', @game.format_currency(@game.player_interest(@player))),
          ])
        end

        if @game.respond_to?(:bidding_power)
          trs << h(:tr, [
            h(:td, 'Bid Power'),
            h('td.right', @game.format_currency(@game.bidding_power(@player))),
          ])
        end
        trs << h(:tr, [
          h(:td, 'Certs'),
          h('td.right', td_cert_props, @game.show_game_cert_limit?(@player) ? "#{num_certs}/#{cert_limit}" : num_certs.to_s),
        ])
        trs << h(:tr, [
          h(:td, 'Shares'),
          h('td.right', td_cert_props, (@game.all_corporations.sum { |c| c.minor? ? 0 : num_shares_of(@player, c) }).to_s),
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
        trs << render_priority_deal(priority_props) if @game.show_priority_deal_player?(order) &&
                                                       @player == @game.priority_deal_player
        trs << render_next_sr_position(priority_props) if %i[first_to_pass most_cash least_cash].include?(order) &&
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

        show_percent = @game.show_player_percent?(@player)
        president_marker = corporation.president?(@player) ? '*' : ''
        double_markers = 'd' * shares.count(&:double_cert)
        children << h(:td, td_props, corporation.name + president_marker + double_markers)
        children << h('td.right', td_props, show_percent ? "#{shares.sum(&:percent)}%" : shares.size.to_s)
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
