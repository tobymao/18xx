# frozen_string_literal: true
# rubocop:disable all

require_relative 'models'

Dir['./models/**/*.rb'].sort.each { |file| require file }
Sequel.extension :pg_json_ops

def migrate_all()
  DB[:users].each do |params|
    user = User[params[:id]]
    next unless user.settings&.keys.include?('notifications')

    original = user.settings['notifications']
    next if original.is_a?(String)
    
    begin
      user.settings['notifications'] = original ? 'email' : 'none'
      user.save
    rescue
      puts "Unable to save id=#{user.id} name='#{user.name}'"
    end
  end
end
