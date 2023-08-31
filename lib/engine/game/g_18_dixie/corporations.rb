# frozen_string_literal: true

module Engine
  module Game
    module G18Dixie
      module Corporations
        CORPORATIONS = [
          {
            type: 'major',
            float_percent: 50,
            sym: 'ACL',
            name: 'Atlantic Coast Line',
            logo: '18_ga/ACL',
            simple_logo: '18_ga/ACL.alt',
            tokens: [0, 40, 100, 100],
            coordinates: 'M25',
            color: 'black',
          },
          {
            type: 'major',
            float_percent: 50,
            sym: 'CoG',
            name: 'Central of Georgia Railroad',
            logo: '18_ga/CoG',
            simple_logo: '18_ga/CoG.alt',
            tokens: [0, 40, 100],
            coordinates: 'I19',
            color: 'red',
          },
          {
            type: 'major',
            float_percent: 50,
            sym: 'Fr',
            name: 'Frisco',
            logo: '18_ms/Fr',
            simple_logo: '18_ms/Fr.alt',
            tokens: [0, 40, 100],
            coordinates: 'J2',
            color: '#ed1c24',
          },
          {
            type: 'major',
            float_percent: 50,
            sym: 'IC',
            name: 'Illinois Central Railroad',
            logo: '18_ms/IC',
            simple_logo: '18_ms/IC.alt',
            tokens: [0, 40],
            coordinates: 'D6',
            color: '#397641',
          },
          {
            type: 'major',
            float_percent: 50,
            sym: 'L&N',
            name: 'Louisville and Nashville Railroad',
            logo: '18_ms/LN',
            simple_logo: '18_ms/LN.alt',
            tokens: [0, 40],
            coordinates: 'A13',
            color: '#0d5ba5',
          },
          {
            type: 'major',
            float_percent: 50,
            sym: 'SAL',
            name: 'Seaboard Air Line',
            logo: '18_ga/SAL',
            simple_logo: '18_ga/SAL.alt',
            tokens: [0, 40, 100],
            coordinates: 'J26',
            color: 'gold',
            text_color: 'black',
          },
          {
            type: 'major',
            float_percent: 50,
            sym: 'SR',
            name: 'Southern Railway',
            logo: '18_fl/SR',
            simple_logo: '18_fl/SR.alt',
            tokens: [0, 40, 100, 100],
            coordinates: 'C17',
            city: 1,
            color: '#76a042',
          },
          {
            type: 'major',
            float_percent: 50,
            sym: 'WRA',
            name: 'Western Railway of Alabama',
            logo: '18_ms/WRA',
            simple_logo: '18_ms/WRA.alt',
            tokens: [0, 40, 100],
            coordinates: 'J12',
            color: '#c7c4e2',
            text_color: 'black',
          },
          {
            type: 'system',
            capitalization: 'none',
            sym: 'ICG',
            name: 'Illinois Central Gulf Railway',
            logo: '18_dixie/ICG.alt',
            simple_logo: '18_dixie/ICG.alt',
            tokens: [100, 100],
            shares: [20, 10, 10, 10, 10, 10, 10, 20],
            color: '#FFF',
            text_color: 'black',
            abilities: [
              {
                type: 'train_buy',
                description: 'Inter train buy/sell at face value',
                face_value: true,
              },
              {
                type: 'train_limit',
                increase: 3,
                description: '3 train limit',
              },
              {
                type: 'description',
                description: 'Cannot form if SCL forms first',
                desc_detail: 'If a corporation buys both the first 4D and 5D, the order that the trains were purchased '\
                             ' the order in which SCL and ICG formation is evaluated',
              },
              {
                type: 'description',
                description: '$200 Subsidy',
                desc_detail: 'The ICG gets an additional $200 subsidy from the bank if & when it forms',
              },
              {
                type: 'description',
                description: 'Forms from a merger of IC and Frisco.',
                desc_detail: 'Both IC and Frisco needs to have floated and have operated at least once for the merger to '\
                             'be considered. Both the presidents of the IC and Frisco need to consent for the merger to take '\
                             'place. IC presidency is tiebreaker for ICG presidency. Up to 6 IC and Frisco tokens are exchanged '\
                             'for ICG tokens with any excess and unplaced tokens being lost. The ICG has 2 additional $100 '\
                             'tokens it may lay. The initial stock value of the '\
                             'ICG will be the highest stock value on the top row of the stock market that is both less than '\
                             'the sum of the stock values of the IC & Frisco and also no greater than $160. The president of '\
                             'the IC will get the 20% ICG presidency certificate and the president of the ICG will get the '\
                             'special 20% ICG certificate by exchanging any combination of IC or SCG shares to get to 40% and '\
                             'paying the bank for a 10% share of the ICG to cover any inability to get to 40%, entering '\
                             'emergency money rasing and bankruptcy if needed. After the 20% shares are distributed, players, '\
                             'starting with the new president must exchange IC+Frisco pairs of shares for ICG shares - '\
                             'presidency is not affected. Afterwards, players, starting with the president choose to either '\
                             'trade in or sell remaining IC and Frisco shares for half the current market price of the ICG. '\
                             'After everyone finishes trading, the presidency is re-evaluated and the token exchange is done. '\
                             'The ICG starts with a $200 subsidy, and inherits all trains and money from the IC and Frisco. '\
                             'The merger will lower the certificate limit by 1 for the rest of the game',
              },
            ],
          },
          {
            type: 'system',
            capitalization: 'none',
            sym: 'SCL',
            name: 'Seaboard Coast Line',
            logo: '18_dixie/SCL.alt',
            simple_logo: '18_dixie/SCL.alt',
            tokens: [100, 100],
            color: '#777',
            text_color: 'black',
            shares: [20, 10, 10, 10, 10, 10, 10, 20],
            abilities: [
              {
                type: 'train_buy',
                description: 'Inter train buy/sell at face value',
                face_value: true,
              },
              {
                type: 'train_limit',
                increase: 3,
                description: '3 train limit',
              },
              {
                type: 'description',
                description: 'Cannot form if ICG forms first',
                desc_detail: 'If a corporation buys both the first 4D and 5D, the order that the trains were purchased '\
                             ' the order in which SCL and ICG formation is evaluated',
              },
              {
                type: 'description',
                description: '$100 Subsidy',
                desc_detail: 'The SCL gets an additional $100 subsidy from the bank if & when it forms',
              },
              {
                type: 'description',
                description: 'Forms from a merger of ACL and SAL.',
                desc_detail: 'Both ACL and SAL needs to have floated and have operated at least once for the merger to '\
                             'be considered. Both the presidents of the ACL and SAL need to consent for the merger to take '\
                             'place. ACL presidency is tiebreaker for SCL presidency. Up to 6 ACL and SAL tokens are '\
                             'exchanged for SCL tokens with any excess and unplaced tokens being lost. The SCL has two '\
                             'additional $100 tokens it may lay. The initial stock '\
                             'value of the SCL will be the highest stock value on the top row of the stock market that is '\
                             'both less than the sum of the stock values of the ACL & SAL and also no greater than $160. '\
                             'The president of the ACL will get the 20% SCL presidency certificate and the president of the '\
                             'SCL will get the special 20% SCL certificate by exchanging any combination of ACL or SCG shares '\
                             'to get to 40% and paying the bank for a 10% share of the SCL to cover any inability to get to '\
                             '40%, entering emergency money rasing and bankruptcy if needed. After the 20% shares '\
                             'are distributed, players, starting with the new president must exchange ACL+SAL pairs of shares '\
                             'for SCL shares - presidency is not affected. Afterwards, players, starting with the president '\
                             'choose to either trade in or sell remaining ACL and SAL shares for half the current market price '\
                             'of the SCL. After everyone finishes trading, the presidency is re-evaluated and the token '\
                             'exchange is done. The SCL starts with a $100 subsidy, and inherits all trains and money '\
                             'from the ACL and SAL. The merger will lower the certificate limit by 1 for the rest of the game',
              },
            ],
          },
          # Minors

        ].freeze
      end
    end
  end
end
