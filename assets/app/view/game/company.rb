# frozen_string_literal: true

require 'lib/settings'
require 'lib/truncate'
require 'view/game/actionable'
require 'view/game/alternate_companies'

module View
  module Game
    class Company < Snabberb::Component
      include Actionable
      include Lib::Settings
      include AlternateCompanies

      needs :company
      needs :bids, default: nil
      needs :selected_company, default: nil, store: true
      needs :tile_selector, default: nil, store: true
      needs :display, default: 'inline-block'
      needs :layout, default: nil
      needs :interactive, default: true

      def selected?
        return @step.company_selected?(@company) if @step.respond_to?(:company_selected?)

        @company == @selected_company
      end

      def select_company(event)
        event.JS.stopPropagation
        entity = @game.current_entity
        selected_company = selected? ? nil : @company

        if selected_company && @game.round.actions_for(entity).include?('assign') &&
          (@game.class::ALL_COMPANIES_ASSIGNABLE || entity.respond_to?(:assign!))
          return process_action(Engine::Action::Assign.new(entity, target: selected_company))
        end

        if @game.round.actions_for(entity).include?('select_multiple_companies')
          @step.select_company(entity, @company)
          return store(:selected_company, nil)
        end

        store(:tile_selector, nil, skip: true)
        store(:selected_company, selected_company)
      end

      def render_bidders
        table_props = {
          style: {
            margin: '0 auto',
            borderSpacing: '0 1px',
            fontWeight: 'normal',
          },
        }

        rows = @bids
          .sort_by(&:price)
          .reverse.map.with_index do |bid, i|
            bg_color =
              if setting_for(:show_player_colors, @game)
                player_colors(@game.players)[bid.entity]
              elsif @user && bid.entity.name == @user['name']
                color_for(i.zero? ? :green : :yellow)
              else
                color_for(:bg)
              end
            props = {
              style: {
                backgroundColor: bg_color,
                color: contrast_on(bg_color),
              },
            }
            h(:tr, props, [
              h('td.left', bid.entity.name.truncate(20)),
              h('td.right', bid.price >= 0 ? @game.format_currency(bid.price) : '--'),
            ])
          end

        h(:div, { style: { clear: 'both' } }, [
           h(:label, 'Bidders:'),
           h(:table, table_props, [
             h(:tbody, [
               *rows,
             ]),
           ]),
        ])
      end

      def render
        @step = @game.round.active_step
        # use alternate view of corporation if needed
        if @game.respond_to?(:company_view) && (view = @game.company_view(@company))
          return send("render_#{view}")
        end

        if @layout == :table
          @hidden_divs = {}
          render_company_on_card(@company)
        else
          header_style = {
            background: @company.color,
            color: @company.text_color,
            border: '1px solid',
            borderRadius: '5px',
            marginBottom: '0.5rem',
            fontSize: '90%',
          }

          description_style = {
            margin: '0.5rem 0',
            fontSize: '80%',
            textAlign: 'left',
            fontWeight: 'normal',
            whiteSpace: 'pre-line',
          }

          value_style = {
            float: 'left',
          }

          revenue_style = {
            float: 'right',
          }

          bidders_style = {
            marginTop: '0.5rem',
            display: 'inline-block',
            clear: 'both',
            width: '100%',
          }

          props = {
            style: {
              cursor: 'pointer',
              boxSizing: 'border-box',
              padding: '0.5rem',
              margin: '0.5rem 5px 0 0',
              textAlign: 'center',
              fontWeight: 'bold',
            },
            on: { click: ->(event) { select_company(event) } },
          }
          if selected?
            props[:style][:backgroundColor] = 'lightblue'
            props[:style][:color] = 'black'
            props[:style][:border] = '1px solid'
          end
          props[:style][:display] = @display

          revenue_str = if @game.respond_to?(:company_revenue_str)
                          @game.company_revenue_str(@company)
                        elsif @company.revenue
                          @game.format_currency(@company.revenue)
                        else
                          ''
                        end

          company_name_str = @game.respond_to?(:company_size) ? "[#{@game.company_size(@company)}] " : ''
          company_name_str += @company.name

          children = [
            h(:div, { style: header_style }, @game.company_header(@company)),
            h(:div, company_name_str),
            h(:div, { style: description_style }, @company.desc),
          ]
          children << h(:div, { style: value_style }, "Value: #{@game.format_currency(@company.value)}") if @company.value
          children << h(:div, { style: revenue_style }, "Revenue: #{revenue_str}") if @company.revenue
          unless @company.discount.zero?
            children << h(:div, { style: { float: 'center' } }, "Price: #{@game.format_currency(@company.min_bid)}")
          end
          children << render_bidders if @bids && !@bids.empty?

          if @company.owner && @game.show_company_owners?
            children << h('div.nowrap', { style: bidders_style },
                          "Owner: #{@company.owner.name}")
          end
          if @game.company_status_str(@company)
            status_style = {
              marginTop: '0.5rem',
              clear: 'both',
              display: 'inline-block',
              justifyContent: 'center',
              width: '100%',
              backgroundColor: color_for(:bg2),
              color: color_for(:font2),
            }
            children << h(:div, { style: status_style }, @game.company_status_str(@company))
          end

          unless @interactive
            factor = color_for(:bg2).to_s[1].to_i(16) > 7 ? 0.3 : 0.6
            props[:style][:backgroundColor] = convert_hex_to_rgba(color_for(:bg2), factor)
            props[:style][:border] = '1px dashed'
          end

          h('div.company.card', props, children)
        end
      end

      def toggle_desc(event, company)
        event.JS.stopPropagation
        elm = Native(@hidden_divs[company.sym]).elm
        elm.style.display = elm.style.display == 'none' ? 'grid' : 'none'
      end

      def render_company_on_card(company)
        title_str = @game.respond_to?(:company_size) ? "[#{@game.company_size(company)}] company: " : ''
        title_str += company.name
        company_name_str = @game.respond_to?(:company_size_str) ? "[#{@game.company_size_str(company)}] " : ''
        company_name_str += company.name

        extra = []
        if (uses = company.ability_uses)
          extra << "#{uses[0]}/#{uses[1]}"
          title_str += if uses[0].zero?
                         ', ability already used'
                       elsif uses[1] > 1
                         ", #{uses[0]} ability use#{uses[0] > 1 ? 's' : ''} left"
                       else
                         ', ability still usable'
                       end
        end
        extra << " #{@game.company_status_str(company)}" if @game.company_status_str(company)

        name_props = {
          attrs: { title: "#{title_str}, click to toggle description" },
          style: {
            cursor: 'pointer',
            grid: '1fr / 1fr auto',
            gap: '0 0.2rem',
          },
          on: { click: ->(event) { toggle_desc(event, company) } },
        }
        is_possessed = @company.owner&.player? || @game.players.any? { |p| p.unsold_companies.include?(@company) } ||
                       @game.show_value_of_companies?(@company.owner)
        hidden_props = {
          style: {
            display: 'none',
            gridColumnEnd: "span #{is_possessed ? '3' : '2'}",
            marginBottom: '0.5rem',
            padding: '0.1rem 0.2rem',
            fontSize: '80%',
          },
        }
        @hidden_divs[company.sym] = h(:div, hidden_props, company.desc)
        revenue_str = if @game.respond_to?(:company_revenue_str)
                        @game.company_revenue_str(company)
                      else
                        @game.format_currency(company.revenue)
                      end

        [h(:div, name_props, [h('span.nowrap', company_name_str), h(:span, extra)]),
         @game.show_value_of_companies?(company.owner) ? h('div.right', @game.format_currency(company.value)) : '',
         h('div.padded_number', revenue_str),
         @hidden_divs[company.sym]]
      end
    end
  end
end
