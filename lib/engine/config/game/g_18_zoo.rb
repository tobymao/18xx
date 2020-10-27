# frozen_string_literal: true

# rubocop:disable Lint/RedundantCopDisableDirective, Layout/LineLength, Layout/HeredocIndentation

module Engine
  module Config
    module Game
      module G18ZOO
        JSON = <<-'DATA'
{
   "filename":"18_zoo",
   "modulename":"18ZOO",
   "currencyFormatStr":"$%d",
   "bankCash":99999,
   "capitalization":"incremental",
   "layout":"flat",
   "axes":{
      "rows":"numbers",
      "columns":"letters"
   },
   "mustSellInBlocks":true,
   "locationNames":{
   },
   "tiles":{
   },
   "market":[
    ["7", "8", "9", "10", "11", "12"  , "13", "14", "15", "16", "20", "24"],
    ["6", "7p", "8",  "9", "10", "11", "12", "13", "14"],
    ["5", "6p", "7",  "8",  "9", "10", "11"],
    ["4", "5p", "6",  "7",  "8"],
    ["3", "4", "5"],
    ["2", "3"]
   ],
   "companies":[
      {
         "sym":"1",
         "name":"VACANZA",
         "value":3,
         "desc":"Un buon viaggio che solo i ricchi possono permettersi: durante un SR, aumenta la reputazione di una famiglia a piacere di un tick a destra, e scarta il potere."
      },
      {
         "sym":"2",
         "name":"RE MIDA",
         "value":2,
         "desc":"Dopo che tutti hanno passato in un SR (fine SR), prima di assegnare l’ordine di turno, tutti credono che tu sia il più ricco, guadagni il segnalino di turno 1, e scarti il potere."
      },
      {
         "sym":"3",
         "name":"TROPPA RESPONSABILITA’",
         "value":1,
         "desc":"Più poteri più responsabilità, preferisci un regalino – ricevi subito (una volta) 3$N. Scarta il potere dopo l’utilizzo."
      },
      {
         "sym":"4",
         "name":"PENTOLA DEGLI GNOMI",
         "value":2,
         "desc":"Guadagni immediatamente 2$N; inoltre guadagni 2$N ad ogni inizio di SR 2$N – PREZZEMOLO NELLE ORECCHIE: ci senti male, e pensi di aver sentito tutti passare; dopo aver giocato il proprio turno nell’SR (VENDITA e/o ACQUISTO), scarta il potere e fai immediatamente un altro turno."
      },
      {
         "sym":"5",
         "name":"PREZZEMOLO NELLE ORECCHIE",
         "value":2,
         "desc":"Ci senti male, e pensi di aver sentito tutti passare; dopo aver giocato il proprio turno nell’SR (VENDITA e/o ACQUISTO), scarta il potere e fai immediatamente un altro turno."
      },
      {
         "sym":"6",
         "name":"WHATSUP",
         "value":3,
         "desc":"Conosco uno che corre bene; se una famiglia che controlli ha in tesoreria $N sufficienti ad acquistare il primo scoiattolo disponibile, scarta il potere e la famiglia lo acquista (durante l’SR). La reputazione della famiglia avanza di un tick (anche se lo scoiattolo è il primo di una nuova fase, e la nuova fase scatta). Lo scoiattolo acquistato è disattivato (piazzarlo sottosopra): durante la successiva CORSA non corre, ma ritorna utilizzabile alla fine del turno operativo – anche disattivato può essere acquistato."
      },
      {
         "sym":"7",
         "name":"CONIGLI",
         "value":3,
         "desc":"I due token si possono utilizzare per 2 sostituzioni aggiuntive (al primo utilizzo scarta un coniglio, al secondo utilizzo scarta coniglio e potere); la sostituzione con i conigli permette di usare una traccia anche se non ancora disponibile (es. sostituzione di una traccia verde con una traccia marrone prima della fase MARRONE); permette di sostituire tracce con i token MM, M, O (e il token rimane sulla nuova tessera). È VIETATO l’upgrade delle tracce speciali posizionate con le TALPE."
      },
      {
         "sym":"8",
         "name":"TALPE",
         "value":3,
         "desc":"La famiglia ha a disposizione 4 tracce speciali (#80,81,82,83) che può utilizzare per sostituire delle tracce semplici (#7,8,9) raggiungibili (rispettando i normali vincoli di piazzamento). E’ permesso sostituire anche tracce semplici con i token MM, M, O. Il potere va scartato dopo aver utilizzato tutte e 4 le tracce. Le tracce speciali (#80,81,82,83) non potranno mai essere sostituite."
      },
      {
         "sym":"9",
         "name":"VECCHIE MAPPE",
         "value":2,
         "desc":"Ritrovi un progetto dei precedenti animali, costruisci (una volta sola) due tracce gialle in aggiunta alle normali tracce posizionate nel turno, e scarta il potere."
      },
      {
         "sym":"10",
         "name":"BUCA",
         "value":2,
         "desc":"Scarta il potere, e contrassegna due Zone R qualsiasi della mappa, che diventano connesse per tutte le famiglie. Le due Zone R sono quindi da considerare come fossero una sola zona R unica. Gli scoiattoli possono passare attraverso la Zona R unica nelle corse come se fosse una stazione libera, con il vincolo che ogni scoiattolo può utilizzarla solo una volta, e non può uscire ed entrare dalla stessa. Scoiattoli multipli possono passare dalla zona R unica solo se fuoriescono da uscite differenti."
      },
      {
         "sym":"11",
         "name":"DIETA",
         "value":2,
         "desc":"I tuoi scoiattoli sono magri magri, e lo spazio necessario a riposarsi è ridotto, puoi usare questo potere per mettere un deposito in aggiunta agli spazi consentiti. Posiziona il deposito di lato per ricordare che è sempre in aggiunta al massimo numero di depositi possibili sulla traccia – scarta il potere. Non permette di posizionare un deposito aggiuntivo a quello permesso per turno (uno solo)."
      },
      {
         "sym":"12",
         "name":"ORO CHE LUCCICA",
         "value":1,
         "desc":"Ogni volta che si costruisce sulle M invece di pagare -1$N, la famiglia guadagna +2$N; nel caso di MM, invece di pagare -2$N, guadagna +1$N."
      },
      {
         "sym":"13",
         "name":"QUELLA E’ MIA!",
         "value":2,
         "desc":"Prenota un posto libero di una traccia stazione (ovunque in mappa, anche se non raggiungibile), che rimane aperta per la corsa di tutte le famiglie. La famiglia che ha prenotato la stazione può piazzare un proprio deposito dove riservato, solo se arriva lì con un percorso (corsa infinita); solo in questo caso il potere si esaurisce e si scarta. Se la famiglia che ha riservato il posto, ha terminato i propri depositi, il posto rimane comunque riservato (aperto per tutte le corse). VIETATO prenotare l’unico spazio RISERVATO per la HOME di una famiglia non ancora operativa."
      },
      {
         "sym":"14",
         "name":"LAVORI IN CORSO",
         "value":2,
         "desc":"Gli scavi durano un po’ più del previsto: posiziona il token dei lavori in corso in un posto libero di una traccia stazione – HOME o Y – ovunque in mappa, (anche se non raggiungibile), e scarta il potere. Quella stazione non potrà mai essere occupata con un deposito (es. in figura, la traccia risulta “impassabile”; con la sostituzione in traccia verde sarà possibile aprire di nuovo il percorso). VIETATO bloccare l’unico spazio RISERVATO della HOME di una famiglia non ancora operativa."
      },
      {
         "sym":"15",
         "name":"GRANO",
         "value":2,
         "desc":"Scarta il potere e seleziona una traccia con un proprio deposito (es le giraffe hanno un deposito sulla tessera #14), posizionaci sopra il GRANO; ogni corsa della famiglia con questo potere, quando passa o termina nel deposito con il GRANO, raccoglierà +30 Noci (nell’esempio 30+30 = 60)."
      },
      {
         "sym":"16",
         "name":"DUE BORRACCE",
         "value":2,
         "desc":"La famiglia può scegliere di non raccogliere le O in tesoreria, ma di raddoppiare il loro valore (contare +20 invece che +10) per tutte le O percorse con tutti i suoi scoiattoli durante la corsa. La famiglia prenderà 0$N indipendentemente da quante O percorre (al primo utilizzo scarta una Borraccia, al secondo utilizzo scarta Borraccia e potere). VIETATO l’utilizzo combinato con la STRIZZATA."
      },
      {
         "sym":"17",
         "name":"UNA STRIZZATA",
         "value":3,
         "desc":"Gli scoiattoli si bagnano i vestiti, e strizzandoli si trova altra acqua. La famiglia prende ulteriori 3$N se almeno uno scoiattolo percorre una O. VIETATO l’utilizzo combinato con la BORRACCIA."
      },
      {
         "sym":"18",
         "name":"BENDA",
         "value":2,
         "desc":"Uno scoiattolo non ci vede, e continua a correre anche se pensionato, ma inciampa sempre e fa una corsa con solo un deposito (corre come se fosse un 1S). Lo scoiattolo con la BENDA non può essere venduto. Finché lo scoiattolo ha la benda, la famiglia mantiene il potere attivo; in ogni momento può decidere di rimuovere la benda e cestinare lo scoiattolo – scartando il potere. La famiglia non può acquistare scoiattoli, a meno di cestinare la BENDA. Il potere si può assegnare in qualsiasi momento (anche se non è il turno operativo della famiglia – ad es. quando un’altra famiglia acquista uno scoiattolo che cambia la FASE), ma in questo caso il giocatore che offre la BENDA non riceverà alcun compenso. È possibile assegnare la BENDA al 4S o 3S LUNGO."
      },
      {
         "sym":"19",
         "name":"ALI",
         "value":2,
         "desc":"Solo durante la corsa, uno scoiattolo a piacere può saltare una traccia impassabile (tutte le tracce stazioni occupate da depositi di altre famiglie), senza però conteggiare il valore della provvista della stazione. Non può essere utilizzato per saltare una traccia stazione con un proprio deposito, o con uno spazio libero. Una stazione con un solo spazio, bloccato da LAVORI IN CORSO, non può essere saltata."
      },
      {
         "sym":"20",
         "name":"BASTA UN POCO DI ZUCCHERO",
         "value":3,
         "desc":"Uno scoiattolo a piacere corre una fermata in più (es. un 2S corre come un 3S, un 3S corre come un 4S...) – non è applicabile agli scoiattoli 4J o 2J. VIETATO utilizzo con lo scoiattolo con la BENDA."
      }
   ],
   "trains":[
      {
         "name":"2S",
         "distance":2,
         "price":7,
         "rusts_on":"4S",
         "num":1
      },
      {
         "name":"3S",
         "distance":3,
         "price":12,
         "rusts_on":"5S",
         "num":4
      },
      {
         "name":"4S",
         "distance":4,
         "price":20,
         "rusts_on":"4J/2J",
         "num":3
      },
      {
         "name":"5S",
         "distance":5,
         "price":30,
         "num":2
      },
      {
         "name":"4J",
         "distance":4,
         "price":47,
         "num":20
      },
      {
         "name":"2J",
         "distance":2,
         "price":37,
         "num":20,
         "available_on":"4J"
      }
   ],
   "phases":[
      {
         "name":"2S",
         "train_limit":4,
         "tiles":[
            "yellow"
         ],
         "status":[
            "can_buy_companies"
         ],
         "operating_rounds": 2
      },
      {
         "name":"3S",
         "on":"3S",
         "train_limit":3,
         "tiles":[
            "yellow",
            "green"
         ],
         "status":[
            "can_buy_companies"
         ],
         "operating_rounds": 2
      },
      {
         "name":"4S",
         "on":"4S",
         "train_limit":3,
         "tiles":[
            "yellow",
            "green"
         ],
         "status":[
            "can_buy_companies"
         ],
         "operating_rounds": 2
      },
      {
         "name":"5S",
         "on":"5S",
         "train_limit":2,
         "tiles":[
            "yellow",
            "green",
            "brown"
         ],
         "operating_rounds": 2
      },
      {
         "name":"4J/2J",
         "on":"4J",
         "train_limit":2,
         "tiles":[
            "yellow",
            "green",
            "brown",
            "gray"
         ],
         "operating_rounds": 3
      }
   ]
}
        DATA
      end

      module G18ZOOMapA
        JSON = <<-'DATA'
{
  "certLimit": {
    "2": 10,
    "3": 7,
    "4": 5
  },
  "startingCash": {
    "2": 40,
    "3": 28,
    "4": 23
  },
  "corporations":[
      {
         "sym":"H2",
         "float_percent": 40,
         "name":"GIRAFFES",
         "logo":"18_zoo/giraffe",
         "tokens":[
            0,
            2
         ],
         "coordinates":"A4",
         "color":"#fff793"
      },
      {
         "sym":"H3",
         "float_percent": 40,
         "name":"POLAR BEARS",
         "logo":"18_zoo/polar-bear",
         "tokens":[
            0,
            2,
            4,
            4
         ],
         "coordinates":"A4",
         "color":"#efebeb"
      },
      {
         "sym":"H4",
         "float_percent": 40,
         "name":"PENGUINS",
         "logo":"18_zoo/penguin",
         "tokens":[
            0,
            2,
            4,
            4
         ],
         "coordinates":"A4",
         "color":"#55b7b7"
      },
      {
         "sym":"H5",
         "float_percent": 40,
         "name":"LIONS",
         "logo":"18_zoo/lion",
         "tokens":[
            0,
            2,
            4
         ],
         "coordinates":"A4",
         "color":"#df251a"
      },
      {
         "sym":"H6",
         "float_percent": 40,
         "name":"TIGERS",
         "logo":"18_zoo/tiger",
         "tokens":[
            0,
            2
         ],
         "coordinates":"A4",
         "color":"#ffa023"
    }
  ],
  "hexes":{
    "gray":{
      "": [
        "B9","C8","J5","L13"
      ],
      "path=a:0,b:5":[
        "A10"
      ],
      "path=a:3,b:5":[
        "A12"
      ],
      "path=a:0,b:3":[
        "F9"
      ],
      "offboard=revenue:0,hide:1;path=a:0,b:_0;path=a:4,b:_0":[
        "D7"
      ],
      "offboard=revenue:0,hide:1;path=a:3,b:_0":[
        "F21"
      ],
      "path=a:1,b:4,track:narrow;path=a:3,b:5":[
        "G16"
      ],
      "path=a:2,b:3":[
        "G20"
      ],
      "junction;path=a:0,b:_0;path=a:2,b:_0;path=a:4,b:_0":[
        "H3"
      ],
      "offboard=revenue:0,hide:1;path=a:1,b:_0;path=a:0,b:0":[
        "H13"
      ],
      "path=a:4,b:0":[
        "J7"
      ],
      "path=a:2,b:4":[
        "J19"
      ],
      "path=a:1,b:3;path=a:3,b:5":[
        "K6"
      ],
      "path=a:4,b:0;path=a:4,b:1":[
        "L15"
      ],
      "path=a:2,b:5":[
        "L7"
      ],
      "path=a:0,b:2":[
        "M8"
      ],
      "offboard=revenue:0,hide:1;path=a:5,b:_0":[
        "L9"
      ],
      "offboard=revenue:0,hide:1;path=a:1,b:_0":[
        "K8","L3","N9"
      ],
      "offboard=revenue:0,hide:1;path=a:2,b:_0":[
        "I6","K10"
      ]
    },
    "green":{
      "offboard=revenue:yellow_20|brown_40,hide:1,groups:E|SW|NW;label=Y":[
        "D9","F19","J15","K4"
      ]
    },
    "blue":{
      "":[
        "B11","B13","E18","G10","H9","H11","I2","K14","M12","M14"
      ]
    },
    "red":{
      "offboard=revenue:yellow_20|brown_40,hide:1,groups:E|SW|NW;label=M2": [
        "D11","E10","F17","G18","J3","K18","M16"
      ],
      "offboard=revenue:yellow_20|brown_40,hide:1,groups:E|SW|NW;label=M1": [
        "C12","H15","I14","D17"
      ],
      "offboard=revenue:yellow_30|brown_60;path=a:3,b:_0;path=a:4,b:_0;label=R":[
        "B17"
      ],
      "offboard=revenue:yellow_20|brown_40,hide:1,groups:E|SW|NW;label=H2":[
        "J9"
      ],
      "offboard=revenue:yellow_20|brown_40,hide:1,groups:E|SW|NW;label=H3":[
        "M10"
      ],
      "offboard=revenue:yellow_20|brown_40,hide:1,groups:E|SW|NW;label=H4":[
        "J17"
      ],
      "offboard=revenue:yellow_20|brown_40,hide:1,groups:E|SW|NW;label=H5":[
        "D15"
      ],
      "offboard=revenue:yellow_20|brown_40,hide:1,groups:E|SW|NW;label=H6":[
        "G14"
      ],
      "offboard=revenue:yellow_30|brown_60;path=a:2,b:_0;label=R":[
        "L5","M18"
      ],
      "offboard=revenue:yellow_30|brown_60;path=a:4,b:_0;label=R":[
        "E8"
      ],
      "offboard=revenue:yellow_30|brown_60;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=R":[
        "H19"
      ]
    },
    "white":{
      "":[
        "I4","H5","F7","H7","G8","I8",
        "C10","I10","F11","J11","L11","E12","G12","I12","K12","D13",
        "F13","J13","C14","E14","B15","F15","C16","E16","I16","K16",
        "H17","L17","I18"
      ]
    }
  }
}
        DATA
      end

      module G18ZOOMapB
        JSON = <<-'DATA'
{
  "certLimit": {
    "2": 10,
    "3": 7,
    "4": 5
  },
  "startingCash": {
    "2": 40,
    "3": 28,
    "4": 23
  },
  "corporations":[
      {
         "sym":"H1",
         "float_percent": 40,
         "name":"CROCODILES",
         "logo":"18_zoo/crocodile",
         "tokens":[
            0,
            2,
            4,
            4
         ],
         "coordinates":"A1",
         "color":"#00af14"
      },
      {
         "sym":"H2",
         "float_percent": 40,
         "name":"GIRAFFES",
         "logo":"18_zoo/giraffe",
         "tokens":[
            0,
            2
         ],
         "coordinates":"A4",
         "color":"#fff793"
      },
      {
         "sym":"H3",
         "float_percent": 40,
         "name":"POLAR BEARS",
         "logo":"18_zoo/polar-bear",
         "tokens":[
            0,
            2,
            4,
            4
         ],
         "coordinates":"A4",
         "color":"#efebeb"
      },
      {
         "sym":"H4",
         "float_percent": 40,
         "name":"PENGUINS",
         "logo":"18_zoo/penguin",
         "tokens":[
            0,
            2,
            4,
            4
         ],
         "coordinates":"A4",
         "color":"#55b7b7"
      },
      {
         "sym":"H5",
         "float_percent": 40,
         "name":"LIONS",
         "logo":"18_zoo/lion",
         "tokens":[
            0,
            2,
            4
         ],
         "coordinates":"A4",
         "color":"#df251a"
      },
      {
         "sym":"H6",
         "float_percent": 40,
         "name":"TIGERS",
         "logo":"18_zoo/tiger",
         "tokens":[
            0,
            2
         ],
         "coordinates":"A4",
         "color":"#ffa023"
      },
      {
         "sym":"H7",
         "float_percent": 40,
         "name":"BROWN BEARS",
         "logo":"18_zoo/brown-bear",
         "tokens":[
            0,
            2,
            4
         ],
         "coordinates":"A4",
         "color":"#ae6d1d"
      },
      {
         "sym":"H8",
         "float_percent": 40,
         "name":"ELEPHANTS",
         "logo":"18_zoo/elephant",
         "tokens":[
            0,
            2,
            4,
            4
         ],
         "coordinates":"A4",
         "color":"#858585"
      }
   ],
   "hexes":{
      "white":{
         "":[
                   "B0",       "D0",       "F0",       "H0",       "J0",       "L0",       "N0",       "P0",        "R0",      "T0",       "V0",       "X0",       "Z0",
             "A1",       "C1",       "E1",       "G1",       "I1",       "K1",       "M1",       "O1",       "Q1",       "S1",       "U1",       "W1",       "Y1",
                   "B2",       "D2",       "F2",       "H2",       "J2",       "L2",       "N2",       "P2",        "R2",      "T2",       "V2",       "X2",       "Z2",
             "A3",       "C3",       "E3",       "G3",       "I3",       "K3",       "M3",       "O3",       "Q3",       "S3",       "U3",       "W3",       "Y3",
                   "B4",       "D4",       "F4",       "H4",       "J4",       "L4",       "N4",       "P4",        "R4",      "T4",       "V4",       "X4",       "Z4",
             "A5",       "C5",       "E5",       "G5",       "I5",       "K5",       "M5",       "O5",       "Q5",       "S5",       "U5",       "W5",       "Y5",
                   "B6",       "D6",       "F6",       "H6",       "J6",       "L6",       "N6",       "P6",        "R6",      "T6",       "V6",       "X6",       "Z6",
             "A7",       "C7",       "E7",       "G7",       "I7",       "K7",       "M7",       "O7",       "Q7",       "S7",       "U7",       "W7",       "Y7",
                   "B8",       "D8",       "F8",       "H8",       "J8",       "L8",       "N8",       "P8",        "R8",      "T8",       "V8",       "X8",       "Z8",
             "A9",       "C9",       "E9",       "G9",       "I9",       "K9",       "M9",       "O9",       "Q9",       "S9",       "U9",       "W9",       "Y9",
                  "B10",      "D10",      "F10",      "H10",      "J10",      "L10",      "N10",      "P10",      "R10",      "T10",      "V10",      "X10",      "Z10",
            "A11",      "C11",      "E11",      "G11",      "I11",      "K11",      "M11",      "O11",      "Q11",      "S11",      "U11",      "W11",      "Y11",
                  "B12",      "D12",      "F12",      "H12",      "J12",      "L12",      "N12",      "P12",      "R12",      "T12",      "V12",      "X12",      "Z12",
            "A13",      "C13",      "E13",      "G13",      "I13",      "K13",      "M13",      "O13",      "Q13",      "S13",      "U13",      "W13",      "Y13",
                  "B14",      "D14",      "F14",      "H14",      "J14",      "L14",      "N14",      "P14",      "R14",      "T14",      "V14",      "X14",      "Z14",
            "A15",      "C15",      "E15",      "G15",      "I15",      "K15",      "M15",      "O15",      "Q15",      "S15",      "U15",      "W15",      "Y15",
                  "B16",      "D16",      "F16",      "H16",      "J16",      "L16",      "N16",      "P16",      "R16",      "T16",      "V16",      "X16",      "Z16",
            "A17",      "C17",      "E17",      "G17",      "I17",      "K17",      "M17",      "O17",      "Q17",      "S17",      "U17",      "W17",      "Y17",
                  "B18",      "D18",      "F18",      "H18",      "J18",      "L18",      "N18",      "P18",      "R18",      "T18",      "V18",      "X18",      "Z18",
            "A19",      "C19",      "E19",      "G19",      "I19",      "K19",      "M19",      "O19",      "Q19",      "S19",      "U19",      "W19",      "Y19",
                  "B20",      "D20",      "F20",      "H20",      "J20",      "L20",      "N20",      "P20",      "R20",      "T20",      "V20",      "X20",      "Z20"
        ]
      }
   }
}
        DATA
      end

      module G18ZOOMapC
        JSON = <<-'DATA'
{
  "certLimit": {
    "2": 10,
    "3": 7,
    "4": 5
  },
  "startingCash": {
    "2": 40,
    "3": 28,
    "4": 23
  },
  "corporations":[
      {
         "sym":"H1",
         "float_percent": 40,
         "name":"CROCODILES",
         "logo":"18_zoo/crocodile",
         "tokens":[
            0,
            2,
            4,
            4
         ],
         "coordinates":"A1",
         "color":"#00af14"
      },
      {
         "sym":"H2",
         "float_percent": 40,
         "name":"GIRAFFES",
         "logo":"18_zoo/giraffe",
         "tokens":[
            0,
            2
         ],
         "coordinates":"A4",
         "color":"#fff793"
      },
      {
         "sym":"H3",
         "float_percent": 40,
         "name":"POLAR BEARS",
         "logo":"18_zoo/polar-bear",
         "tokens":[
            0,
            2,
            4,
            4
         ],
         "coordinates":"A4",
         "color":"#efebeb"
      },
      {
         "sym":"H4",
         "float_percent": 40,
         "name":"PENGUINS",
         "logo":"18_zoo/penguin",
         "tokens":[
            0,
            2,
            4,
            4
         ],
         "coordinates":"A4",
         "color":"#55b7b7"
      },
      {
         "sym":"H5",
         "float_percent": 40,
         "name":"LIONS",
         "logo":"18_zoo/lion",
         "tokens":[
            0,
            2,
            4
         ],
         "coordinates":"A4",
         "color":"#df251a"
      },
      {
         "sym":"H6",
         "float_percent": 40,
         "name":"TIGERS",
         "logo":"18_zoo/tiger",
         "tokens":[
            0,
            2
         ],
         "coordinates":"A4",
         "color":"#ffa023"
      },
      {
         "sym":"H7",
         "float_percent": 40,
         "name":"BROWN BEARS",
         "logo":"18_zoo/brown-bear",
         "tokens":[
            0,
            2,
            4
         ],
         "coordinates":"A4",
         "color":"#ae6d1d"
      },
      {
         "sym":"H8",
         "float_percent": 40,
         "name":"ELEPHANTS",
         "logo":"18_zoo/elephant",
         "tokens":[
            0,
            2,
            4,
            4
         ],
         "coordinates":"A4",
         "color":"#858585"
      }
   ],
   "hexes":{
      "white":{
         "":[
                   "B0",       "D0",       "F0",       "H0",       "J0",       "L0",       "N0",       "P0",        "R0",      "T0",       "V0",       "X0",       "Z0",
             "A1",       "C1",       "E1",       "G1",       "I1",       "K1",       "M1",       "O1",       "Q1",       "S1",       "U1",       "W1",       "Y1",
                   "B2",       "D2",       "F2",       "H2",       "J2",       "L2",       "N2",       "P2",        "R2",      "T2",       "V2",       "X2",       "Z2",
             "A3",       "C3",       "E3",       "G3",       "I3",       "K3",       "M3",       "O3",       "Q3",       "S3",       "U3",       "W3",       "Y3",
                   "B4",       "D4",       "F4",       "H4",       "J4",       "L4",       "N4",       "P4",        "R4",      "T4",       "V4",       "X4",       "Z4",
             "A5",       "C5",       "E5",       "G5",       "I5",       "K5",       "M5",       "O5",       "Q5",       "S5",       "U5",       "W5",       "Y5",
                   "B6",       "D6",       "F6",       "H6",       "J6",       "L6",       "N6",       "P6",        "R6",      "T6",       "V6",       "X6",       "Z6",
             "A7",       "C7",       "E7",       "G7",       "I7",       "K7",       "M7",       "O7",       "Q7",       "S7",       "U7",       "W7",       "Y7",
                   "B8",       "D8",       "F8",       "H8",       "J8",       "L8",       "N8",       "P8",        "R8",      "T8",       "V8",       "X8",       "Z8",
             "A9",       "C9",       "E9",       "G9",       "I9",       "K9",       "M9",       "O9",       "Q9",       "S9",       "U9",       "W9",       "Y9",
                  "B10",      "D10",      "F10",      "H10",      "J10",      "L10",      "N10",      "P10",      "R10",      "T10",      "V10",      "X10",      "Z10",
            "A11",      "C11",      "E11",      "G11",      "I11",      "K11",      "M11",      "O11",      "Q11",      "S11",      "U11",      "W11",      "Y11",
                  "B12",      "D12",      "F12",      "H12",      "J12",      "L12",      "N12",      "P12",      "R12",      "T12",      "V12",      "X12",      "Z12",
            "A13",      "C13",      "E13",      "G13",      "I13",      "K13",      "M13",      "O13",      "Q13",      "S13",      "U13",      "W13",      "Y13",
                  "B14",      "D14",      "F14",      "H14",      "J14",      "L14",      "N14",      "P14",      "R14",      "T14",      "V14",      "X14",      "Z14",
            "A15",      "C15",      "E15",      "G15",      "I15",      "K15",      "M15",      "O15",      "Q15",      "S15",      "U15",      "W15",      "Y15",
                  "B16",      "D16",      "F16",      "H16",      "J16",      "L16",      "N16",      "P16",      "R16",      "T16",      "V16",      "X16",      "Z16",
            "A17",      "C17",      "E17",      "G17",      "I17",      "K17",      "M17",      "O17",      "Q17",      "S17",      "U17",      "W17",      "Y17",
                  "B18",      "D18",      "F18",      "H18",      "J18",      "L18",      "N18",      "P18",      "R18",      "T18",      "V18",      "X18",      "Z18",
            "A19",      "C19",      "E19",      "G19",      "I19",      "K19",      "M19",      "O19",      "Q19",      "S19",      "U19",      "W19",      "Y19",
                  "B20",      "D20",      "F20",      "H20",      "J20",      "L20",      "N20",      "P20",      "R20",      "T20",      "V20",      "X20",      "Z20"
        ]
      }
   }
}
        DATA
      end

      module G18ZOOMapD
        JSON = <<-'DATA'
{
  "certLimit": {
    "2": 12,
    "3": 9,
    "4": 7,
    "5": 6
  },
  "startingCash": {
    "2": 48,
    "3": 32,
    "4": 27,
    "5": 22
  },
  "corporations":[
      {
         "sym":"H1",
         "float_percent": 40,
         "name":"CROCODILES",
         "logo":"18_zoo/crocodile",
         "tokens":[
            0,
            2,
            4,
            4
         ],
         "coordinates":"A1",
         "color":"#00af14"
      },
      {
         "sym":"H2",
         "float_percent": 40,
         "name":"GIRAFFES",
         "logo":"18_zoo/giraffe",
         "tokens":[
            0,
            2
         ],
         "coordinates":"A4",
         "color":"#fff793"
      },
      {
         "sym":"H3",
         "float_percent": 40,
         "name":"POLAR BEARS",
         "logo":"18_zoo/polar-bear",
         "tokens":[
            0,
            2,
            4,
            4
         ],
         "coordinates":"A4",
         "color":"#efebeb"
      },
      {
         "sym":"H4",
         "float_percent": 40,
         "name":"PENGUINS",
         "logo":"18_zoo/penguin",
         "tokens":[
            0,
            2,
            4,
            4
         ],
         "coordinates":"A4",
         "color":"#55b7b7"
      },
      {
         "sym":"H5",
         "float_percent": 40,
         "name":"LIONS",
         "logo":"18_zoo/lion",
         "tokens":[
            0,
            2,
            4
         ],
         "coordinates":"A4",
         "color":"#df251a"
      },
      {
         "sym":"H6",
         "float_percent": 40,
         "name":"TIGERS",
         "logo":"18_zoo/tiger",
         "tokens":[
            0,
            2
         ],
         "coordinates":"A4",
         "color":"#ffa023"
      },
      {
         "sym":"H7",
         "float_percent": 40,
         "name":"BROWN BEARS",
         "logo":"18_zoo/brown-bear",
         "tokens":[
            0,
            2,
            4
         ],
         "coordinates":"A4",
         "color":"#ae6d1d"
      },
      {
         "sym":"H8",
         "float_percent": 40,
         "name":"ELEPHANTS",
         "logo":"18_zoo/elephant",
         "tokens":[
            0,
            2,
            4,
            4
         ],
         "coordinates":"A4",
         "color":"#858585"
      }
   ],
   "hexes":{
      "white":{
         "":[
                   "B0",       "D0",       "F0",       "H0",       "J0",       "L0",       "N0",       "P0",        "R0",      "T0",       "V0",       "X0",       "Z0",
             "A1",       "C1",       "E1",       "G1",       "I1",       "K1",       "M1",       "O1",       "Q1",       "S1",       "U1",       "W1",       "Y1",
                   "B2",       "D2",       "F2",       "H2",       "J2",       "L2",       "N2",       "P2",        "R2",      "T2",       "V2",       "X2",       "Z2",
             "A3",       "C3",       "E3",       "G3",       "I3",       "K3",       "M3",       "O3",       "Q3",       "S3",       "U3",       "W3",       "Y3",
                   "B4",       "D4",       "F4",       "H4",       "J4",       "L4",       "N4",       "P4",        "R4",      "T4",       "V4",       "X4",       "Z4",
             "A5",       "C5",       "E5",       "G5",       "I5",       "K5",       "M5",       "O5",       "Q5",       "S5",       "U5",       "W5",       "Y5",
                   "B6",       "D6",       "F6",       "H6",       "J6",       "L6",       "N6",       "P6",        "R6",      "T6",       "V6",       "X6",       "Z6",
             "A7",       "C7",       "E7",       "G7",       "I7",       "K7",       "M7",       "O7",       "Q7",       "S7",       "U7",       "W7",       "Y7",
                   "B8",       "D8",       "F8",       "H8",       "J8",       "L8",       "N8",       "P8",        "R8",      "T8",       "V8",       "X8",       "Z8",
             "A9",       "C9",       "E9",       "G9",       "I9",       "K9",       "M9",       "O9",       "Q9",       "S9",       "U9",       "W9",       "Y9",
                  "B10",      "D10",      "F10",      "H10",      "J10",      "L10",      "N10",      "P10",      "R10",      "T10",      "V10",      "X10",      "Z10",
            "A11",      "C11",      "E11",      "G11",      "I11",      "K11",      "M11",      "O11",      "Q11",      "S11",      "U11",      "W11",      "Y11",
                  "B12",      "D12",      "F12",      "H12",      "J12",      "L12",      "N12",      "P12",      "R12",      "T12",      "V12",      "X12",      "Z12",
            "A13",      "C13",      "E13",      "G13",      "I13",      "K13",      "M13",      "O13",      "Q13",      "S13",      "U13",      "W13",      "Y13",
                  "B14",      "D14",      "F14",      "H14",      "J14",      "L14",      "N14",      "P14",      "R14",      "T14",      "V14",      "X14",      "Z14",
            "A15",      "C15",      "E15",      "G15",      "I15",      "K15",      "M15",      "O15",      "Q15",      "S15",      "U15",      "W15",      "Y15",
                  "B16",      "D16",      "F16",      "H16",      "J16",      "L16",      "N16",      "P16",      "R16",      "T16",      "V16",      "X16",      "Z16",
            "A17",      "C17",      "E17",      "G17",      "I17",      "K17",      "M17",      "O17",      "Q17",      "S17",      "U17",      "W17",      "Y17",
                  "B18",      "D18",      "F18",      "H18",      "J18",      "L18",      "N18",      "P18",      "R18",      "T18",      "V18",      "X18",      "Z18",
            "A19",      "C19",      "E19",      "G19",      "I19",      "K19",      "M19",      "O19",      "Q19",      "S19",      "U19",      "W19",      "Y19",
                  "B20",      "D20",      "F20",      "H20",      "J20",      "L20",      "N20",      "P20",      "R20",      "T20",      "V20",      "X20",      "Z20"
        ]
      }
   }
}
        DATA
      end

      module G18ZOOMapE
        JSON = <<-'DATA'
{
  "certLimit": {
    "2": 12,
    "3": 9,
    "4": 7,
    "5": 6
  },
  "startingCash": {
    "2": 48,
    "3": 32,
    "4": 27,
    "5": 22
  },
  "corporations":[
      {
         "sym":"H1",
         "float_percent": 40,
         "name":"CROCODILES",
         "logo":"18_zoo/crocodile",
         "tokens":[
            0,
            2,
            4,
            4
         ],
         "coordinates":"A1",
         "color":"#00af14"
      },
      {
         "sym":"H2",
         "float_percent": 40,
         "name":"GIRAFFES",
         "logo":"18_zoo/giraffe",
         "tokens":[
            0,
            2
         ],
         "coordinates":"A4",
         "color":"#fff793"
      },
      {
         "sym":"H3",
         "float_percent": 40,
         "name":"POLAR BEARS",
         "logo":"18_zoo/polar-bear",
         "tokens":[
            0,
            2,
            4,
            4
         ],
         "coordinates":"A4",
         "color":"#efebeb"
      },
      {
         "sym":"H4",
         "float_percent": 40,
         "name":"PENGUINS",
         "logo":"18_zoo/penguin",
         "tokens":[
            0,
            2,
            4,
            4
         ],
         "coordinates":"A4",
         "color":"#55b7b7"
      },
      {
         "sym":"H5",
         "float_percent": 40,
         "name":"LIONS",
         "logo":"18_zoo/lion",
         "tokens":[
            0,
            2,
            4
         ],
         "coordinates":"A4",
         "color":"#df251a"
      },
      {
         "sym":"H6",
         "float_percent": 40,
         "name":"TIGERS",
         "logo":"18_zoo/tiger",
         "tokens":[
            0,
            2
         ],
         "coordinates":"A4",
         "color":"#ffa023"
      },
      {
         "sym":"H7",
         "float_percent": 40,
         "name":"BROWN BEARS",
         "logo":"18_zoo/brown-bear",
         "tokens":[
            0,
            2,
            4
         ],
         "coordinates":"A4",
         "color":"#ae6d1d"
      },
      {
         "sym":"H8",
         "float_percent": 40,
         "name":"ELEPHANTS",
         "logo":"18_zoo/elephant",
         "tokens":[
            0,
            2,
            4,
            4
         ],
         "coordinates":"A4",
         "color":"#858585"
      }
   ],
   "hexes":{
      "white":{
         "":[
                   "B0",       "D0",       "F0",       "H0",       "J0",       "L0",       "N0",       "P0",        "R0",      "T0",       "V0",       "X0",       "Z0",
             "A1",       "C1",       "E1",       "G1",       "I1",       "K1",       "M1",       "O1",       "Q1",       "S1",       "U1",       "W1",       "Y1",
                   "B2",       "D2",       "F2",       "H2",       "J2",       "L2",       "N2",       "P2",        "R2",      "T2",       "V2",       "X2",       "Z2",
             "A3",       "C3",       "E3",       "G3",       "I3",       "K3",       "M3",       "O3",       "Q3",       "S3",       "U3",       "W3",       "Y3",
                   "B4",       "D4",       "F4",       "H4",       "J4",       "L4",       "N4",       "P4",        "R4",      "T4",       "V4",       "X4",       "Z4",
             "A5",       "C5",       "E5",       "G5",       "I5",       "K5",       "M5",       "O5",       "Q5",       "S5",       "U5",       "W5",       "Y5",
                   "B6",       "D6",       "F6",       "H6",       "J6",       "L6",       "N6",       "P6",        "R6",      "T6",       "V6",       "X6",       "Z6",
             "A7",       "C7",       "E7",       "G7",       "I7",       "K7",       "M7",       "O7",       "Q7",       "S7",       "U7",       "W7",       "Y7",
                   "B8",       "D8",       "F8",       "H8",       "J8",       "L8",       "N8",       "P8",        "R8",      "T8",       "V8",       "X8",       "Z8",
             "A9",       "C9",       "E9",       "G9",       "I9",       "K9",       "M9",       "O9",       "Q9",       "S9",       "U9",       "W9",       "Y9",
                  "B10",      "D10",      "F10",      "H10",      "J10",      "L10",      "N10",      "P10",      "R10",      "T10",      "V10",      "X10",      "Z10",
            "A11",      "C11",      "E11",      "G11",      "I11",      "K11",      "M11",      "O11",      "Q11",      "S11",      "U11",      "W11",      "Y11",
                  "B12",      "D12",      "F12",      "H12",      "J12",      "L12",      "N12",      "P12",      "R12",      "T12",      "V12",      "X12",      "Z12",
            "A13",      "C13",      "E13",      "G13",      "I13",      "K13",      "M13",      "O13",      "Q13",      "S13",      "U13",      "W13",      "Y13",
                  "B14",      "D14",      "F14",      "H14",      "J14",      "L14",      "N14",      "P14",      "R14",      "T14",      "V14",      "X14",      "Z14",
            "A15",      "C15",      "E15",      "G15",      "I15",      "K15",      "M15",      "O15",      "Q15",      "S15",      "U15",      "W15",      "Y15",
                  "B16",      "D16",      "F16",      "H16",      "J16",      "L16",      "N16",      "P16",      "R16",      "T16",      "V16",      "X16",      "Z16",
            "A17",      "C17",      "E17",      "G17",      "I17",      "K17",      "M17",      "O17",      "Q17",      "S17",      "U17",      "W17",      "Y17",
                  "B18",      "D18",      "F18",      "H18",      "J18",      "L18",      "N18",      "P18",      "R18",      "T18",      "V18",      "X18",      "Z18",
            "A19",      "C19",      "E19",      "G19",      "I19",      "K19",      "M19",      "O19",      "Q19",      "S19",      "U19",      "W19",      "Y19",
                  "B20",      "D20",      "F20",      "H20",      "J20",      "L20",      "N20",      "P20",      "R20",      "T20",      "V20",      "X20",      "Z20"
        ]
      }
   }
}
        DATA
      end

      module G18ZOOMapF
        JSON = <<-'DATA'
{
  "certLimit": {
    "2": 12,
    "3": 9,
    "4": 7,
    "5": 6
  },
  "startingCash": {
    "2": 48,
    "3": 32,
    "4": 27,
    "5": 22
  },
  "corporations":[
      {
         "sym":"H1",
         "float_percent": 40,
         "name":"CROCODILES",
         "logo":"18_zoo/crocodile",
         "tokens":[
            0,
            2,
            4,
            4
         ],
         "coordinates":"A1",
         "color":"#00af14"
      },
      {
         "sym":"H2",
         "float_percent": 40,
         "name":"GIRAFFES",
         "logo":"18_zoo/giraffe",
         "tokens":[
            0,
            2
         ],
         "coordinates":"A4",
         "color":"#fff793"
      },
      {
         "sym":"H3",
         "float_percent": 40,
         "name":"POLAR BEARS",
         "logo":"18_zoo/polar-bear",
         "tokens":[
            0,
            2,
            4,
            4
         ],
         "coordinates":"A4",
         "color":"#efebeb"
      },
      {
         "sym":"H4",
         "float_percent": 40,
         "name":"PENGUINS",
         "logo":"18_zoo/penguin",
         "tokens":[
            0,
            2,
            4,
            4
         ],
         "coordinates":"A4",
         "color":"#55b7b7"
      },
      {
         "sym":"H5",
         "float_percent": 40,
         "name":"LIONS",
         "logo":"18_zoo/lion",
         "tokens":[
            0,
            2,
            4
         ],
         "coordinates":"A4",
         "color":"#df251a"
      },
      {
         "sym":"H6",
         "float_percent": 40,
         "name":"TIGERS",
         "logo":"18_zoo/tiger",
         "tokens":[
            0,
            2
         ],
         "coordinates":"A4",
         "color":"#ffa023"
      },
      {
         "sym":"H7",
         "float_percent": 40,
         "name":"BROWN BEARS",
         "logo":"18_zoo/brown-bear",
         "tokens":[
            0,
            2,
            4
         ],
         "coordinates":"A4",
         "color":"#ae6d1d"
      },
      {
         "sym":"H8",
         "float_percent": 40,
         "name":"ELEPHANTS",
         "logo":"18_zoo/elephant",
         "tokens":[
            0,
            2,
            4,
            4
         ],
         "coordinates":"A4",
         "color":"#858585"
      }
   ],
   "hexes":{
      "white":{
         "":[
                   "B0",       "D0",       "F0",       "H0",       "J0",       "L0",       "N0",       "P0",        "R0",      "T0",       "V0",       "X0",       "Z0",
             "A1",       "C1",       "E1",       "G1",       "I1",       "K1",       "M1",       "O1",       "Q1",       "S1",       "U1",       "W1",       "Y1",
                   "B2",       "D2",       "F2",       "H2",       "J2",       "L2",       "N2",       "P2",        "R2",      "T2",       "V2",       "X2",       "Z2",
             "A3",       "C3",       "E3",       "G3",       "I3",       "K3",       "M3",       "O3",       "Q3",       "S3",       "U3",       "W3",       "Y3",
                   "B4",       "D4",       "F4",       "H4",       "J4",       "L4",       "N4",       "P4",        "R4",      "T4",       "V4",       "X4",       "Z4",
             "A5",       "C5",       "E5",       "G5",       "I5",       "K5",       "M5",       "O5",       "Q5",       "S5",       "U5",       "W5",       "Y5",
                   "B6",       "D6",       "F6",       "H6",       "J6",       "L6",       "N6",       "P6",        "R6",      "T6",       "V6",       "X6",       "Z6",
             "A7",       "C7",       "E7",       "G7",       "I7",       "K7",       "M7",       "O7",       "Q7",       "S7",       "U7",       "W7",       "Y7",
                   "B8",       "D8",       "F8",       "H8",       "J8",       "L8",       "N8",       "P8",        "R8",      "T8",       "V8",       "X8",       "Z8",
             "A9",       "C9",       "E9",       "G9",       "I9",       "K9",       "M9",       "O9",       "Q9",       "S9",       "U9",       "W9",       "Y9",
                  "B10",      "D10",      "F10",      "H10",      "J10",      "L10",      "N10",      "P10",      "R10",      "T10",      "V10",      "X10",      "Z10",
            "A11",      "C11",      "E11",      "G11",      "I11",      "K11",      "M11",      "O11",      "Q11",      "S11",      "U11",      "W11",      "Y11",
                  "B12",      "D12",      "F12",      "H12",      "J12",      "L12",      "N12",      "P12",      "R12",      "T12",      "V12",      "X12",      "Z12",
            "A13",      "C13",      "E13",      "G13",      "I13",      "K13",      "M13",      "O13",      "Q13",      "S13",      "U13",      "W13",      "Y13",
                  "B14",      "D14",      "F14",      "H14",      "J14",      "L14",      "N14",      "P14",      "R14",      "T14",      "V14",      "X14",      "Z14",
            "A15",      "C15",      "E15",      "G15",      "I15",      "K15",      "M15",      "O15",      "Q15",      "S15",      "U15",      "W15",      "Y15",
                  "B16",      "D16",      "F16",      "H16",      "J16",      "L16",      "N16",      "P16",      "R16",      "T16",      "V16",      "X16",      "Z16",
            "A17",      "C17",      "E17",      "G17",      "I17",      "K17",      "M17",      "O17",      "Q17",      "S17",      "U17",      "W17",      "Y17",
                  "B18",      "D18",      "F18",      "H18",      "J18",      "L18",      "N18",      "P18",      "R18",      "T18",      "V18",      "X18",      "Z18",
            "A19",      "C19",      "E19",      "G19",      "I19",      "K19",      "M19",      "O19",      "Q19",      "S19",      "U19",      "W19",      "Y19",
                  "B20",      "D20",      "F20",      "H20",      "J20",      "L20",      "N20",      "P20",      "R20",      "T20",      "V20",      "X20",      "Z20"
        ]
      }
   }
}
        DATA
      end
    end
  end
end

# rubocop:enable Lint/RedundantCopDisableDirective, Layout/LineLength, Layout/HeredocIndentation
