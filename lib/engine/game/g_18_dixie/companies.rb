# frozen_string_literal: true

module Engine
  module Game
    module G18Dixie
      module Companies
        COMPANIES = [
          # Available SR1
          {
            name: 'Atlanta, Valdosta & Western Rwy.',
            sym: 'P1',
            value: 20,
            revenue: 5,
            desc: 'Owner may allow a Corporation controlled by the owner to lay a tile in a river hex at no cost. '\
                  'This can be an extra tile lay if desired. Taking this action closes the Private Company.',
            color: nil,
          },
          {
            name: 'Atlanta, St. Andrews Bay Railway Co.',
            sym: 'P2',
            value: 30,
            revenue: 10,
            desc: 'Owner may place a +$10 token on any city or town within 4 hexes of Dothan (L14). Place the other token on '\
                  'the assigned Corporation\'s charter during its operating turn. The token adds +$10 to the value of the city '\
                  'for all trains that Corporation runs to the tokened city or town. This income bonus *never expires* and can '\
                  'never be given or sold to another railroad. It can be inherited by the SCL or ICG if assigned to the '\
                  'predecessor Corporations. Assigning the token to a Corporation closes the Private Company',
            color: nil,
          },
          {
            name: 'Atlanta & West Point Railroad',
            sym: 'P3',
            value: 50,
            revenue: 15,
            desc: 'This Private Company reserves a token slot in Atlanta. A placeholder token is placed as soon as the Private '\
                  'Company is purchased. This token blocks routes. During a Corporation\'s operating turn, the owner of this '\
                  'Private Company may place an extra free token in Atlanta replacing the placeholder token with an extra '\
                  'Corporation\s token that they control. This extra token may be transferred to the SCL or ICG if it belonged '\
                  'to a predecessor company. Exchanging the token closes the Private Company. If the placeholder token is not '\
                  'prior to the start of phase 6 when the Minor COmpanies close, it is removed from Atlanta and any Corporation '\
                  'may place a token there, using normal token placement rules',
            color: nil,
          },
          {
            name: 'Derrick, Carver & Thomas, RR Accountants',
            sym: 'P4',
            value: 50,
            revenue: 10,
            desc: 'At any time during a company\'s operating turn, or just prior to a stock round, the owner may take the '\
                  'priority deal from the current holder (including themself) and an extra immediate payment of $10 from the '\
                  'bank. Taking this action closes the Private Company.',
            color: nil,
          },
          {
            name: 'Alabama Great Southern Railroad',
            sym: 'P5',
            value: 80,
            revenue: 10,
            desc: 'The owner may use this Private Company to allow a COrporatio nthey are president of to purchase a train from '\
                  'the depot for 50% of the listed prive *at any time* during that operating companys turn. This is an '\
                  'exception to rule [4.7] regarding when trains can be bought. If this option is used prior to the purchase '\
                  'of the first 6+1 train, it counts as the only allowed train purchase from the depot by that company. '\
                  'Using this special ability closes the Private Company',
            color: nil,
          },
          {
            name: 'South Carolina Canal and Rail Road Company',
            sym: 'P6',
            value: 140,
            revenue: 0,
            desc: 'The purchaser of this Private Company immediately receives teh 20% president\'s certificate of the Southern '\
                  'Railway. The owner then immediately sets the par value for the Southern Railway, places 3 regular shares '\
                  'of the Southern Railway into the Open Market (thus it is floated and will operate with no further '\
                  'share purchases), and discards this Private Company. As long as this Private Company is in the game and '\
                  'unbought, the Southern Railway\'s president\'s share is reserved.',
            abilities: [{ type: 'shares', shares: 'SR_0' }],
            color: nil,
          },
          # Available SR2
          {
            name: 'New Athens Yards',
            sym: 'P7',
            value: 100,
            revenue: 15,
            desc: 'The owner of this Private Company may assign one or two spare parts tokens to any existing trains owned by '\
                  'a Corporation of which they are the president. This must be done during the Corporation\'s operating turn. '\
                  'The spare parts tokens give the trains delayed obsolecense as described in section [4.6]. If assigning two '\
                  'tokens, both tokens must be assigned at the same time and to the same non-permanent train. Assigning either '\
                  'or both tokens closes the Private Company. THese tokens cannot be reassigned to another train but the trains '\
                  'can transfer to the SCL or ICG if previously assigned to a train owned by a predecessor. Once assigned '\
                  'to a train, that train cannot be sold to any other Corporation.',
            color: nil,
          },
          {
            name: '"Pan American" Pullman Service',
            sym: 'P8',
            value: 50,
            revenue: 15,
            desc: 'Comes with an assignable +$20/+$30 Pan American token which can be placed on any train belonging to a '\
                  'Corporation at any time. Placing the token closes the Private Company and adds to the income of a run. '\
                  'The +$30 side is used if assigned to a train owned by the IC, Frisco, ACL or WRA. The +$20 side is '\
                  'used if assigned to a train owned by all other companies. Once placed on a train, this token can never be '\
                  'transferred, nor can that train be sold to any other Corporation, although it could be inherited by the '\
                  'SCL (if placed on a 5 Train). If neither token has been placed when phase 6 begins, this ability is lost. '\
                  'The token is removed as soon as the train it was assigned to is scrapped.',
            color: nil,
          },
          {
            name: 'Dixie Flyer Pullman Service',
            sym: 'P9',
            value: 110,
            revenue: 5,
            desc: 'This Private Company comes with a 1D+1 Train. When the Private Companies close at the start of Phase 6, the '\
                  'owner may assign the 1D+1 train to a Corporation that they are president of at no cost. It may not be '\
                  'assigned to a Corporation at any other time. If the owner chooses not to assign the train to a Corporation, '\
                  'it is removed from the game. If the 1D+1 Train causes the owning company to exceed its train limit, its '\
                  'President must choose a train to be discarded. If the 1D+1 is discarded, it is removed from the game '\
                  'instead of being placed in the Open Market',
            color: nil,
          },
          {
            name: 'Western Railway of Alabama',
            sym: 'P10',
            value: 150,
            revenue: 0,
            desc: 'The purchaser of this Private Company immediately receives teh 20% president\'s certificate of the WRA '\
                  '. The owner then immediately sets the par value for the WRA, places 3 regular shares of the '\
                  'WRA into the Open Market (thus it is floated and will operate with no further share purchases), '\
                  'and discards this Private Company. As long as this Private Company is in the game and unbought, the WRA'\
                  '\'s president\'s share is reserved.',
            abilities: [{ type: 'shares', shares: 'WRA_0' }],
            color: nil,
          },
        ].freeze
      end
    end
  end
end
