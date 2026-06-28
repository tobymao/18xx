# frozen_string_literal: true

require 'user_manager'

module View
  class Admin < Snabberb::Component
    include UserManager

    needs :admin_bans, default: [], store: true
    needs :admin_bans_loaded, default: false, store: true
    needs :admin_lookup, default: nil, store: true

    def render
      return h(:div, 'Admin access required.') unless @user&.dig('settings', 'admin')

      load_bans unless @admin_bans_loaded

      h(:div, [
        h(:h2, 'Ban Management'),
        render_lookup,
        render_bans,
        render_form,
      ])
    end

    def load_bans
      store(:admin_bans_loaded, true, skip: true)
      @connection.safe_get('/admin/bans') do |data|
        store(:admin_bans, data['bans'] || [], skip: false)
      end
    end

    def render_lookup
      @lookup_input = h(:input, attrs: { placeholder: 'Username' })

      children = [
        h(:h3, 'Look up user'),
        h(:div, [@lookup_input]),
        h(:button, { on: { click: -> { lookup } } }, 'Search'),
      ]

      if @admin_lookup
        found = @admin_lookup
        children << h(:div, [
          h(:p, "Name: #{found['name']}"),
          h(:p, "Email: #{found['email']}"),
          h(:button, { on: { click: -> { ban_user(found) } } }, 'Ban user + IP(s)'),
          render_ips(found['ips'] || []),
        ])
      end

      h(:div, children)
    end

    def render_ips(ips)
      return h(:p, 'No known IPs.') if ips.empty?

      h(:div, ips.map do |entry|
        ip = entry['ip']
        h(:div, { style: { marginTop: '0.5rem' } }, [
          h(:div, [
            h(:span, "IP: #{ip} "),
            h(:button, { on: { click: -> { create_ban(ip: ip) } } }, 'Ban IP'),
          ]),
          render_others(entry['others'] || []),
        ])
      end)
    end

    def render_others(others)
      return h(:div, { style: { marginLeft: '1rem' } }, 'No other accounts on this IP.') if others.empty?

      rows = others.map do |other|
        h(:div, [
          h(:span, "#{other['name']} "),
          h(:button, { on: { click: -> { create_ban(name: other['name']) } } }, 'Ban account'),
        ])
      end

      h(:div, { style: { marginLeft: '1rem' } }, [h(:div, 'Other accounts on this IP:')] + rows)
    end

    def lookup
      @connection.safe_post('/admin/lookup', name: Native(@lookup_input).elm.value) do |data|
        store(:admin_lookup, data['user'], skip: false)
      end
    end

    def render_bans
      return h(:p, 'No active bans.') if @admin_bans.empty?

      rows = @admin_bans.map do |ban|
        h(:tr, [
          h(:td, ban['user_name'] || ''),
          h(:td, ban['ip'] || ''),
          h(:td, ban['reason'] || ''),
          h(:td, ban['created_by'] || ''),
          h(:td, [h(:button, { on: { click: -> { remove(ban['id']) } } }, 'Remove')]),
        ])
      end

      h(:table, [
        h(:thead, [h(:tr, [
          h(:th, 'Account'),
          h(:th, 'IP'),
          h(:th, 'Reason'),
          h(:th, 'By'),
          h(:th, ''),
        ])]),
        h(:tbody, rows),
      ])
    end

    def render_form
      @name_input = h(:input, attrs: { placeholder: 'Username or email' })
      @ip_input = h(:input, attrs: { placeholder: 'IP address' })
      @reason_input = h(:input, attrs: { placeholder: 'Reason' })

      h(:div, [
        h(:h3, 'Add ban'),
        h(:div, [@name_input]),
        h(:div, [@ip_input]),
        h(:div, [@reason_input]),
        h(:button, { on: { click: -> { submit } } }, 'Add ban'),
      ])
    end

    def submit
      create_ban(
        name: Native(@name_input).elm.value,
        ip: Native(@ip_input).elm.value,
        reason: Native(@reason_input).elm.value,
      )
    end

    def ban_user(found)
      create_ban(name: found['name'], ips: (found['ips'] || []).map { |entry| entry['ip'] })
    end

    def create_ban(name: '', ip: '', ips: [], reason: '')
      @connection.safe_post('/admin/bans', name: name, ip: ip, ips: ips, reason: reason) do |data|
        store(:admin_bans, data['bans'], skip: false)
      end
    end

    def remove(id)
      @connection.safe_post("/admin/bans/#{id}/remove") do |data|
        store(:admin_bans, data['bans'], skip: false)
      end
    end
  end
end
