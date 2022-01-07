# frozen_string_literal: true

module Engine
  module Game
    module G18AZ
      module Entities
        COMPANIES = [


             {
               name: 'El Paso & Southwestern RR',
               value: 40,
               revenue: 15,
               desc: 'May lay 1 or 2 extra yellow tiles at no cost on OR 1.  These no cost tiles may '\
                     'be played in any order with the normal one or two yellow tile lays normally allowed in '\
                     'phase 2.  The extra tile lays must be used to extend existing track.  If this special '\
                     'power is not used in OR 1, it is lost for the rest of the game although the Private Company '\
                     'still pays its income until phase six.  Using this ability does not close the company.',
               sym: 'EPS',
               color: nil,
             },
             {
               name: 'Arizona Tunnel Blasting Company',
               value: 45,
               revenue: 10,
               desc: 'The owning player may lay an extra free yellow tile during the operating turn of '\
                     'a Major Company he controls.  This extra tile lay must be in a mountain hex that is '\
                     'connected to existing track connected to the Major Company’s token.  This free tile lay '\
                     'may be either before or after the normal may of the Major Company.  Using this ability does '\
                     'not close the company.',
               sym: 'ATBC',
               color: nil,
             },
             {
               name: 'Arizona Development Office',
               value: 50,
               revenue: 15,
               desc: 'This Private Company may be closed during the operating turn of a Major Company '\
                     'controlled by the owning player to provide an additional free token that can be used by '\
                     'that Major Company.  This Private Company’s special ability does not allow an extra token '\
                     'placement in the Major Company’s operating turn.  If this special ability is not used '\
                     'before Phase 6, it is lost when the Private Company is closed.',
               sym: 'ADO',
               color: nil,
             },
             {
               name: 'Excelsior Mine Company',
               value: 60,
               revenue: 15,
               desc: 'This Private Company provides a free Ghost Town tile which may be played by a Major '\
                     'Company controlled by the owning player.  The placement must be in a mountain hex that is '\
                     'connected by track to a token of the Major Company.  It is an extra tile lay in addition to '\
                     'the normal tile lay and can be done either before or after the regular tile lay(s) of the '\
                     'Major Company.  If this special ability is not used before phase 6, it is lost.',
               sym: 'EMC',
               color: nil,
             },
             {
               name: 'Texas & Pacific Railway',
               value: 60,
               revenue: 10,
               desc: 'The owning player receives a free 10% share of AT&SF.  When the current value of the '\
                     'AT&SF is set, the bank place the current value of the AT&SF on the company’s charter.  The '\
                     'Private Company closes when the AT&SF pays its next dividend.',
               sym: 'TP',
               color: nil,
             },
             {
               name: 'Arizona & Colorado Railroad',
               value: 70,
               revenue: 10,
               desc: 'This Private Company can be closed at the Train Purchasing part of a Major Company '\
                     'controlled by the owning player, to receive a $150 discount on either a 3Train or a 4Train. '\
                     'If this special ability is not used, it pays the $10 income to the owning player until the '\
                     'start of phase 6.',
               sym: 'ACR',
               color: nil,
             },
             {
               name: 'Arizona Engine Works',
               value: 75,
               revenue: 5,
               desc: 'A Major Company controlled by the owning player may close it at any time during the '\
                     'Major Company’s Operating turn to receive a free 3Train after phase 3 starts.  This exchange '\
                     'may not occur if the Major Company is at its train limit.  This 3Train is a normal train and '\
                     'rusts in phase six when other 3 Trains are rusted.  If this special ability is not used, it '\
                     'continues to pay its income until phase 6 which it is removed from play.',
               sym: 'AEW',
               color: nil,
             },
             {
               name: 'Survey Office',
               value: 50,
               revenue: 10,
               desc: 'This Private Company may be closed to allow a Major Company controlled by the owning player '\
                     'to move a token from the board to its charter where it may be played for free during a future '\
                     'operating round.  A Major Company which uses this special ability must wait until its next operating '\
                     'turn at the earliest to place this free token.  The Major Company is still limited to placing at the '\
                     'most one token per operating round after this ability has been used and the free token must be placed '\
                     'as allowed under the normal token placement rules (for example, it cannot be placed where reserved for '\
                     'unstarted Major Companies and it must be reachable from another token of the same Major Company).  If a '\
                     'Major Company only has one token on the board, this special ability may not be used.  If not used '\
                     'before phase 6, this ability is lost as the Private Company is removed from play.',
               sym: 'SO',
               color: nil,
             },
        ].freeze

        CORPORATIONS = [
          {
            float_percent: 20,
            sym: 'UP',
            name: 'Union Pacific Railroad',
            logo: '1846/PRR',
            simple_logo: '1846/PRR.alt',
            tokens: [0, 80, 80, 80, 80],
            coordinates: 'B1',
            color: :'#FF0000',
            always_market_price: true,
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'ATSF',
            name: 'Atchson',
            logo: '1846/PRR',
            simple_logo: '1846/PRR.alt',
            tokens: [0, 80, 80, 80, 80],
            coordinates: 'M6',
            color: :'#FF0000',
            always_market_price: true,
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'SP',
            name: 'Southern Pacific Railroad',
            logo: '1846/PRR',
            simple_logo: '1846/PRR.alt',
            tokens: [0, 80, 80, 80, 80],
            coordinates: 'M18',
            color: :'#FF0000',
            always_market_price: true,
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'SPP',
            name: 'SPP Railroad',
            logo: '1846/PRR',
            simple_logo: '1846/PRR.alt',
            tokens: [0, 80, 80, 80, 80],
            coordinates: 'E8',
            color: :'#FF0000',
            always_market_price: true,
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'YV',
            name: 'Yuma Valley Railroad',
            logo: '1846/PRR',
            simple_logo: '1846/PRR.alt',
            tokens: [0, 80, 80, 80, 80],
            coordinates: 'B13',
            color: :'#FF0000',
            always_market_price: true,
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'GC',
            name: 'Grand Canyon',
            logo: '1846/PRR',
            simple_logo: '1846/PRR.alt',
            tokens: [0, 80, 80, 80, 80],
            coordinates: 'F3',
            color: :'#FF0000',
            always_market_price: true,
            reservation_color: nil,
          },
          {
            float_percent: 20,
            sym: 'ABC',
            name: 'ABC Railroad',
            logo: '1846/PRR',
            simple_logo: '1846/PRR.alt',
            tokens: [0, 80, 80, 80, 80],
            coordinates: 'F11',
            color: :'#FF0000',
            always_market_price: true,
            reservation_color: nil,
          },
        ].freeze

        MINORS = [


        ].freeze
      end
    end
  end
end
