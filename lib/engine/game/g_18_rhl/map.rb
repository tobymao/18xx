# frozen_string_literal: true

module Engine
  module Game
    module G18Rhl
      module Map
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

          map
        end
      end
    end
  end
end
