# frozen_string_literal: true

require 'user_manager'
require 'view/form'

module View
  class Admin < Form
    include UserManager

    needs :admin_bans, default: [], store: true
    needs :admin_bans_loaded, default: false, store: true
    needs :admin_lookup, default: nil, store: true

    def render_content
      return h(:div, 'Admin access required.') unless @user&.dig('settings', 'admin')

      load_bans unless @admin_bans_loaded

      @lookup_inputs = {}
      @ban_inputs = {}

      h(:div, { style: { maxWidth: '36rem' } }, [
        render_lookup,
        render_bans,
        render_add_ban,
      ])
    end

    def load_bans
      store(:admin_bans_loaded, true, skip: true)
      @connection.safe_get('/admin/bans') do |data|
        store(:admin_bans, data['bans'] || [], skip: false)
      end
    end

    def text_field(label, id, inputs)
      render_input(
        label,
        id: id,
        inputs: inputs,
        label_style: { display: 'block', marginBottom: '0.25rem' },
        input_style: { width: '100%' },
        container_style: { marginBottom: '0.75rem' },
      )
    end

    def render_lookup
      inputs = [
        text_field('Username or email', :name, @lookup_inputs),
        render_button('Search') { lookup },
      ]
      inputs << render_lookup_result if @admin_lookup

      render_form('Look up user', inputs, on_submit: -> { lookup })
    end

    def render_lookup_result
      found = @admin_lookup
      h(:div, { style: { margin: '1rem 0', padding: '0.75rem', border: '1px solid gray', borderRadius: '4px' } }, [
        h(:p, { style: { margin: '0 0 0.25rem' } }, "Name: #{found['name']}"),
        h(:p, { style: { margin: '0 0 0.5rem' } }, "Email: #{found['email']}"),
        text_field('Reason (optional)', :reason, @lookup_inputs),
        ban_action(found['banned'], 'Ban user + all IPs') { ban_user(found) },
        render_ips(found['ips'] || []),
      ])
    end

    # Reason entered on the lookup screen, applied to whichever ban button is clicked.
    def lookup_reason
      params(@lookup_inputs)[:reason].to_s
    end

    # A "Banned" badge if the target is already banned, otherwise a ban button.
    def ban_action(banned, label, &block)
      return h(:span, { style: { color: 'red', fontWeight: 'bold' } }, 'Banned') if banned

      render_button(label, &block)
    end

    def render_ips(ips)
      return h(:p, { style: { marginTop: '0.75rem' } }, 'No known IPs.') if ips.empty?

      h(:div, { style: { marginTop: '0.75rem' } }, ips.map do |entry|
        ip = entry['ip']
        h(:div, { style: { marginTop: '0.5rem' } }, [
          h(:div, [
            h(:span, { style: { marginRight: '0.5rem' } }, "IP: #{ip}"),
            ban_action(entry['banned'], 'Ban IP') { create_ban(ip: ip, reason: lookup_reason) },
          ]),
          render_others(entry['others'] || []),
        ])
      end)
    end

    def render_others(others)
      style = { marginLeft: '1rem', marginTop: '0.25rem' }
      return h(:div, { style: style }, 'No other accounts on this IP.') if others.empty?

      rows = others.map do |other|
        h(:div, { style: { marginTop: '0.25rem' } }, [
          h(:span, { style: { marginRight: '0.5rem' } }, other['name']),
          ban_action(other['banned'], 'Ban account') { create_ban(name: other['name'], reason: lookup_reason) },
        ])
      end

      h(:div, { style: style }, [h(:div, 'Other accounts on this IP:')] + rows)
    end

    def lookup
      @connection.safe_post('/admin/lookup', name: params(@lookup_inputs)[:name]) do |data|
        store(:admin_lookup, data['user'], skip: false)
      end
    end

    def render_bans
      title = h(:h2, { style: { margin: '1.5rem 0 0.5rem' } }, 'Active bans')
      return h(:div, [title, h(:p, 'No active bans.')]) if @admin_bans.empty?

      rows = @admin_bans.map do |ban|
        h(:tr, [
          h(:td, ban['user_name'] || ''),
          h(:td, ban['ip'] || ''),
          h(:td, ban['reason'] || ''),
          h(:td, ban['created_by'] || ''),
          h(:td, [render_button('Remove') { remove(ban['id']) }]),
        ])
      end

      h(:div, [
        title,
        h(:table, [
          h(:thead, [h(:tr, [
            h(:th, 'Account'),
            h(:th, 'IP'),
            h(:th, 'Reason'),
            h(:th, 'By'),
            h(:th, ''),
          ])]),
          h(:tbody, rows),
        ]),
      ])
    end

    def render_add_ban
      inputs = [
        text_field('Username or email', :ban_name, @ban_inputs),
        text_field('IP address', :ban_ip, @ban_inputs),
        text_field('Reason', :ban_reason, @ban_inputs),
        render_button('Add ban') { submit },
      ]
      render_form('Add ban', inputs, on_submit: -> { submit })
    end

    def submit
      values = params(@ban_inputs)
      create_ban(name: values[:ban_name], ip: values[:ban_ip], reason: values[:ban_reason])
    end

    def ban_user(found)
      create_ban(name: found['name'], ips: (found['ips'] || []).map { |entry| entry['ip'] }, reason: lookup_reason)
    end

    def create_ban(name: '', ip: '', ips: [], reason: '')
      @connection.safe_post('/admin/bans', name: name, ip: ip, ips: ips, reason: reason) do |data|
        # Defer the re-render to refresh_lookup when a lookup is on screen, so the
        # bans table and the looked-up user's ban status update together.
        store(:admin_bans, data['bans'], skip: @admin_lookup ? true : false)
        refresh_lookup if @admin_lookup
      end
    end

    def refresh_lookup
      @connection.safe_post('/admin/lookup', name: @admin_lookup['name']) do |data|
        store(:admin_lookup, data['user'], skip: false)
      end
    end

    def remove(id)
      @connection.safe_post("/admin/bans/#{id}/remove") do |data|
        store(:admin_bans, data['bans'], skip: false)
      end
    end
  end
end
