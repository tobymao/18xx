# frozen_string_literal: true

module Engine
  module Game
    module G18Rhl
      module Map
        RATINGEN_HEX = 'E12'

        def base_map
          map = super

          # Modify B7 tile
          map[:gray].delete(['B7'])
          map[:white][['B7']] = 'border=edge:0,type:impassable,color:blue;border=edge:1,type:impassable,color:blue;'\
                                'border=edge:5,type:impassable,color:blue'

          # Modify G2 tile to a red terminal city
          map[:gray].delete(['G2'])
          map[:red][['G2']] = 'city=revenue:yellow_10|brown_20,groups:Roermond;path=a:4,b:_0,terminal:1;'\
                              'icon=image:18_rhl/ERh'

          # Modify H1 to a gray without any entry
          map[:gray][['H1']] = ''

          if optional_ratingen_variant
            map[:white][['E10']] += ';stub=edge:0;stub=edge:2;city=revenue:0'
            map[:white][['E12']] += ';stub=edge:1;icon=image:1893/green_hex;label=R;'\
                                    'icon=image:18_rhl/white_wooden_cube,sticky:1'
          end

          map
        end

        def optional_tiles
          remove_tiles(%w[Essen-0 949-0 950-0 932V-0 932V-1]) unless optional_promotion_tiles
          remove_tiles(%w[932-0 932-1]) if optional_promotion_tiles
          remove_tiles(%w[1910-0 1911-0]) unless optional_ratingen_variant
        end

        def yellow_block_hex
          @yellow_block_hex ||= hex_by_id(RATINGEN_HEX)
        end
      end
    end
  end
end
