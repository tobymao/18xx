# frozen_string_literal: true

class Api
  hash_routes :api do |hr|
    # '/api/admin[/*]'
    hr.on 'admin' do |r|
      not_authorized! unless user&.admin?

      # GET '/api/admin/bans'
      r.get 'bans' do
        { bans: Ban.order(:id).map(&:to_h) }
      end

      r.post do
        # POST '/api/admin/lookup'
        r.is 'lookup' do
          query = r.params['name'].to_s.strip
          found = User.by_email(query) unless query.empty?
          halt(404, 'User not found') unless found

          ips = Session.where(user_id: found.id).select_map(:ip).uniq.reject { |i| i.to_s.empty? }

          others_by_ip = Hash.new { |hash, key| hash[key] = [] }
          unless ips.empty?
            Session.where(ip: ips).exclude(user_id: found.id).distinct.select_map(%i[ip user_id]).each do |ip, uid|
              others_by_ip[ip] << uid
            end
          end
          other_ids = others_by_ip.values.flatten.uniq
          names = User.where(id: other_ids).select_hash(:id, :name)
          banned_user_ids = Ban.where(user_id: [found.id, *other_ids]).select_map(:user_id)
          banned_ips = ips.empty? ? [] : Ban.where(ip: ips).select_map(:ip)

          {
            user: {
              id: found.id,
              name: found.name,
              email: found.email,
              banned: banned_user_ids.include?(found.id),
              ips: ips.map do |ip|
                {
                  ip: ip,
                  banned: banned_ips.include?(ip),
                  others: others_by_ip[ip].uniq.map do |uid|
                    { id: uid, name: names[uid], banned: banned_user_ids.include?(uid) }
                  end,
                }
              end,
            },
          }
        end

        # POST '/api/admin/bans'
        r.is 'bans' do
          name = r.params['name'].to_s.strip
          ips = (Array(r.params['ips']) + [r.params['ip']]).map { |i| i.to_s.strip }.reject(&:empty?).uniq

          account = User.by_email(name) unless name.empty?
          halt(400, 'Account not found') if !name.empty? && account.nil?
          halt(400, 'Enter an account or IP to ban') if account.nil? && ips.empty?

          reason = r.params['reason'].to_s

          if account && !Ban.banned_account?(account.id)
            Ban.create(user: account, reason: reason, created_by: user.id)
            Session.where(user_id: account.id).delete
          end
          ips.each do |ip|
            Ban.create(ip: ip, reason: reason, created_by: user.id) unless Ban.banned_ip?(ip)
          end

          { bans: Ban.order(:id).map(&:to_h) }
        rescue Sequel::UniqueConstraintViolation, Sequel::ValidationFailed
          { bans: Ban.order(:id).map(&:to_h) }
        end

        # POST '/api/admin/bans/<id>/remove'
        r.is 'bans', Integer, 'remove' do |id|
          Ban[id]&.destroy
          { bans: Ban.order(:id).map(&:to_h) }
        end
      end
    end
  end
end
