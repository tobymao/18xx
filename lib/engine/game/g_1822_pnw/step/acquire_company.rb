# frozen_string_literal: true

require_relative '../../../step/route'

module Engine
  module Game
    module G1822PNW
      module Step
        class AcquireCompany < Engine::Step::AcquireCompany
          def actions(entity)
            return ['choose'] if @choices

            super
          end

          def process_acquire_company(action)
            return super unless @game.backroom_company?(action.company)

            @log << "#{action.company.name} closes"
            action.company.close!

            return unless @game.unassociated_minors.include?(action.entity)

            targets = p20_targets
            return if targets.empty?

            @new_associated_minor = action.entity
            @choices = {}
            targets.each do |t|
              @choices[t.name] = "Replace #{t.name} as associated minor for #{@game.major_name_for_associated_minor(t.id)}"
            end
          end

          attr_reader :choices

          def choice_name
            'Pick which associated minor to replace'
          end

          def process_choose(action)
            major = @game.corporation_by_id(@game.major_name_for_associated_minor(action.choice))
            @log << "#{@new_associated_minor.name} replaces #{action.choice} as the associated minor " \
                    "for #{major.id}"
            @game.replace_associated_minor(action.choice, @new_associated_minor.id)
            old_corporation = @game.corporation_by_id(action.choice)
            @log << "#{old_corporation.id} is removed from the game"
            old_corporation.all_abilities.each { |a| @new_associated_minor.add_ability(a) }
            minor_city = @game.hex_by_id(old_corporation.coordinates).tile.cities.find { |c| c.reserved_by?(old_corporation) }

            if minor_city
              minor_city.reservations.delete(old_corporation)
            else
              old_home_city = @game.hex_by_id(major.coordinates).tile.cities.find { |c| c.reserved_by?(major) }
              old_home_city.reservations.delete(major)
            end

            @game.corporations.delete(old_corporation)

            old_company = @game.company_by_id(@game.company_id_from_corp_id(action.choice))
            @new_associated_minor.color = old_company.color
            @new_associated_minor.text_color = old_company.text_color
            @new_associated_minor.logo = "1822_pnw/#{major.id.downcase}/#{@new_associated_minor.name}"
            @new_associated_minor.tokens.first.logo = @new_associated_minor.logo
            @new_associated_minor.tokens.first.simple_logo = @new_associated_minor.logo

            original_home_coordinates = major.coordinates
            @game.remove_home_icon(major, original_home_coordinates)
            @game.add_home_icon(major, @new_associated_minor.coordinates)
            major.coordinates = @new_associated_minor.coordinates

            home_hex = @game.hex_by_id(major.coordinates)
            ability = major.all_abilities.find { |a| a.type == :base && a.description.start_with?('Home: ') }
            ability.description = "Home: #{home_hex.location_name} (#{home_hex.name})"
            @log << "#{major.name}'s home is now #{home_hex.location_name} (#{home_hex.name})"

            # * M3's home is Great Northern's destination
            # * M10's home is Northern Pacific's destination
            # if either of those associations are chosen, the major's original
            # home becomes its new destination
            if major.coordinates == major.destination_coordinates
              dest_coordinates = original_home_coordinates
              major.destination_coordinates = dest_coordinates
              dest_hex = @game.hex_by_id(dest_coordinates)
              ability = major.all_abilities.find { |a| a.type == :base && a.description.start_with?('Destination: ') }
              ability.description = "Destination: #{dest_hex.location_name} (#{dest_hex.name})"
              @log << "#{major.name}'s destination is now #{dest_hex.location_name} (#{dest_hex.name})"

              @game.remove_destination_icon(major, major.coordinates)
              @game.add_destination_icon(major, major.destination_coordinates)
            end

            @game.companies.delete(old_company)

            @choices = nil
          end

          def p20_targets
            bidbox_corporations = @game.bidbox_minors.map { |c| @game.corporation_from_company(c) }
            targets = @game.corporations.select { |c| @game.associated_minor?(c) && !c.owner && !bidbox_corporations.include?(c) }

            # include minors that fell through the bidboxes without bids
            @game.minor_associations.each do |minor_id, major_id|
              company = @game.company_by_id("M#{minor_id}")
              minor = @game.corporation_by_id(minor_id)
              major = @game.corporation_by_id(major_id)

              targets << minor if !company.owner && company.closed? &&
                                  !minor.owner && minor.closed? &&
                                  !major.owner && !major.floated?
            end

            targets
          end
        end
      end
    end
  end
end
