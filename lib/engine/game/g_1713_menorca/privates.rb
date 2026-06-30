# frozen_string_literal: true

module Engine
  module Game
    module G1713Menorca
      module Privates
        COMPANIES = [
          {
            sym: 'GSC',
            name: '1. Gremi de Sabaters de Ciutadella',
            value: 20,
            revenue: 5,
            desc: '+10R to any route that connects Ciutadella with Barcelona, Mallorca, or Marsella. '\
                  'This bonus applies to all corporations using that route if the owner has transferred the ability.',
          },
          {
            sym: 'RAG',
            name: "2. Ramats de l'Albufera d'es Grau",
            value: 20,
            revenue: 5,
            desc: "+15R to any route that starts in S'Albufera d'es Grau. The corporation that acquires this private is the only one "\
                  "that can lay S'Albufera d'es Grau's initial tile by paying the cost shown on the map.",
          },
          {
            sym: 'CRB',
            name: '3. Cami Reial Britanic',
            value: 25,
            revenue: 5,
            desc: "The owning corporation ignores the additional build cost on Cami d'en Kane land hexes during phases 1 and 2.",
            abilities: [{ type: 'close', on_phase: '3' }],
          },
          {
            sym: 'LBI',
            name: "4. Lleves de Bestiar de l'Interior",
            value: 30,
            revenue: 5,
            desc: 'If owned by RAM, the corporation ignores factory blocking from other corporations.  If owned by any other corporation, this ability is inactive.',
          },
          {
            sym: 'FRN',
            name: '5. Factura Pendent amb la Royal Navy',
            value: 100,
            revenue: 10,
            desc: 'During phase 2, owner may exchange this private for one RNC share at current market price without using the stock action. Closes when phase 3 begins.',
            abilities: [
              { type: 'exchange', corporations: ['RNC'], from: %w[ipo market] },
              { type: 'close', on_phase: '3' },
            ],
          },
          {
            sym: 'DRM',
            name: '6. Drassanes Reials de Mao',
            value: 40,
            revenue: 10,
            desc: "Owning corporation buys its first ship in any phase at a 20R discount and can build Torre de l'Illa de l'Aire without additional cost.",
            abilities: [{ type: 'close', on_phase: '4' }],
          },
          {
            sym: 'CSF',
            name: '7. Castell de Sant Felip',
            value: 60,
            revenue: 15,
            desc: 'Once per game, owner may block one route into or out of the port of Mao for one full OR. The block must be declared at the start of the OR.',
            abilities: [{ type: 'close', on_phase: '4' }],
          },
          {
            sym: 'VRC',
            name: '8. Vinculació Familiar amb la Real Compania',
            value: 100,
            revenue: 0,
            desc: 'Upon acquisition, owner immediately receives the RCC family trust share (20%) at no cost. Then this private closes.',
          },
          {
            sym: 'IVR',
            name: '9. Intel·ligència de Versalles',
            value: 35,
            revenue: 10,
            desc: 'Owner sees event cards one round before they trigger. Relevant only when using hidden events variant.',
          },
        ].freeze
      end
    end
  end
end
