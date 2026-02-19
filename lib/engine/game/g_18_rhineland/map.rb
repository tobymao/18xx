# frozen_string_literal: true

module Engine
  module Game
    module G18Rhineland
      module Map
        def modify_map(map)
          # Modify B7 tile
          map[:white].delete(['B7'])
          map[:gray][['B7']] = 'path=a:2,b:4;border=edge:0,type:impassable,color:blue;border=edge:1,type:impassable,color:blue;'\
                               'border=edge:5,type:impassable,color:blue'

          # Modify G2 tile to a red terminal city
          map[:red].delete(['G2'])
          map[:gray][['G2']] = 'city=revenue:yellow_10|brown_20;path=a:4,b:_0;path=a:0,b:_0'

          # Modify H1 to a gray without any entry
          map[:gray].delete(['H1'])
          map[:red][['H1']] = 'offboard=revenue:yellow_0;path=a:3,b:_0,terminal:1;icon=image:18_rhl/ERh'
        end
      end
    end
  end
end
