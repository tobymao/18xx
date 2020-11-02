# frozen_string_literal: true

# rubocop:disable Lint/RedundantCopDisableDirective, Layout/LineLength, Layout/HeredocIndentation

module Engine
  module Config
    module Game
      module G18ZOO
        JSON = <<-'DATA'
{
  "filename": "18_zoo",
  "modulename": "18ZOO",
  "currencyFormatStr": "$%d",
  "bankCash": 99999,
  "capitalization": "incremental",
  "layout": "flat",
  "axes": {
    "rows": "numbers",
    "columns": "letters"
  },
  "mustSellInBlocks": true,
  "certLimit": {
    "2": 0,
    "3": 0,
    "4": 0,
    "5": 0
  },
  "tiles": {
    "7": 6,
    "8": 16,
    "9": 11,
    "5": 2,
    "6": 2,
    "57": 2,
    "201": 2,
    "202": 2,
    "621": 2,
    "19": 1,
    "23": 2,
    "24": 2,
    "25": 2,
    "26": 2,
    "27": 2,
    "28": 1,
    "29": 1,
    "30": 1,
    "31": 1,
    "14": 2,
    "15": 2,
    "619": 2,
    "576": 1,
    "577": 1,
    "579": 1,
    "792": 1,
    "793": 1,
    "40": 1,
    "41": 1,
    "42": 1,
    "43": 1,
    "45": 1,
    "46": 1,
    "611": 3,
    "582": 3,
    "455": 3
  },
  "market": [
    [
      "7",
      "8",
      "9",
      "10",
      "11",
      "12",
      "13",
      "14",
      "15",
      "16",
      "20",
      "24"
    ],
    [
      "6",
      "7p",
      "8",
      "9",
      "10",
      "11",
      "12",
      "13",
      "14"
    ],
    [
      "5",
      "6p",
      "7",
      "8",
      "9",
      "10",
      "11"
    ],
    [
      "4",
      "5p",
      "6",
      "7",
      "8"
    ],
    [
      "3",
      "4",
      "5"
    ],
    [
      "2",
      "3"
    ]
  ],
  "companies": [
    {
      "sym": "1",
      "name": "VACANZA",
      "value": 3,
      "desc": "Un buon viaggio che solo i ricchi possono permettersi: durante un SR, aumenta la reputazione di una famiglia a piacere di un tick a destra, e scarta il potere."
    },
    {
      "sym": "2",
      "name": "RE MIDA",
      "value": 2,
      "desc": "Dopo che tutti hanno passato in un SR (fine SR), prima di assegnare l’ordine di turno, tutti credono che tu sia il più ricco, guadagni il segnalino di turno 1, e scarti il potere."
    },
    {
      "sym": "3",
      "name": "TROPPA RESPONSABILITA’",
      "value": 1,
      "desc": "Più poteri più responsabilità, preferisci un regalino – ricevi subito (una volta) 3$N. Scarta il potere dopo l’utilizzo."
    },
    {
      "sym": "4",
      "name": "PENTOLA DEGLI GNOMI",
      "value": 2,
      "desc": "Guadagni immediatamente 2$N; inoltre guadagni 2$N ad ogni inizio di SR 2$N – PREZZEMOLO NELLE ORECCHIE: ci senti male, e pensi di aver sentito tutti passare; dopo aver giocato il proprio turno nell’SR (VENDITA e/o ACQUISTO), scarta il potere e fai immediatamente un altro turno."
    },
    {
      "sym": "5",
      "name": "PREZZEMOLO NELLE ORECCHIE",
      "value": 2,
      "desc": "Ci senti male, e pensi di aver sentito tutti passare; dopo aver giocato il proprio turno nell’SR (VENDITA e/o ACQUISTO), scarta il potere e fai immediatamente un altro turno."
    },
    {
      "sym": "6",
      "name": "WHATSUP",
      "value": 3,
      "desc": "Conosco uno che corre bene; se una famiglia che controlli ha in tesoreria $N sufficienti ad acquistare il primo scoiattolo disponibile, scarta il potere e la famiglia lo acquista (durante l’SR). La reputazione della famiglia avanza di un tick (anche se lo scoiattolo è il primo di una nuova fase, e la nuova fase scatta). Lo scoiattolo acquistato è disattivato (piazzarlo sottosopra): durante la successiva CORSA non corre, ma ritorna utilizzabile alla fine del turno operativo – anche disattivato può essere acquistato."
    },
    {
      "sym": "7",
      "name": "CONIGLI",
      "value": 3,
      "desc": "I due token si possono utilizzare per 2 sostituzioni aggiuntive (al primo utilizzo scarta un coniglio, al secondo utilizzo scarta coniglio e potere); la sostituzione con i conigli permette di usare una traccia anche se non ancora disponibile (es. sostituzione di una traccia verde con una traccia marrone prima della fase MARRONE); permette di sostituire tracce con i token MM, M, O (e il token rimane sulla nuova tessera). È VIETATO l’upgrade delle tracce speciali posizionate con le TALPE."
    },
    {
      "sym": "8",
      "name": "TALPE",
      "value": 3,
      "desc": "La famiglia ha a disposizione 4 tracce speciali (#80,81,82,83) che può utilizzare per sostituire delle tracce semplici (#7,8,9) raggiungibili (rispettando i normali vincoli di piazzamento). E’ permesso sostituire anche tracce semplici con i token MM, M, O. Il potere va scartato dopo aver utilizzato tutte e 4 le tracce. Le tracce speciali (#80,81,82,83) non potranno mai essere sostituite."
    },
    {
      "sym": "9",
      "name": "VECCHIE MAPPE",
      "value": 2,
      "desc": "Ritrovi un progetto dei precedenti animali, costruisci (una volta sola) due tracce gialle in aggiunta alle normali tracce posizionate nel turno, e scarta il potere."
    },
    {
      "sym": "10",
      "name": "BUCA",
      "value": 2,
      "desc": "Scarta il potere, e contrassegna due Zone R qualsiasi della mappa, che diventano connesse per tutte le famiglie. Le due Zone R sono quindi da considerare come fossero una sola zona R unica. Gli scoiattoli possono passare attraverso la Zona R unica nelle corse come se fosse una stazione libera, con il vincolo che ogni scoiattolo può utilizzarla solo una volta, e non può uscire ed entrare dalla stessa. Scoiattoli multipli possono passare dalla zona R unica solo se fuoriescono da uscite differenti."
    },
    {
      "sym": "11",
      "name": "DIETA",
      "value": 2,
      "desc": "I tuoi scoiattoli sono magri magri, e lo spazio necessario a riposarsi è ridotto, puoi usare questo potere per mettere un deposito in aggiunta agli spazi consentiti. Posiziona il deposito di lato per ricordare che è sempre in aggiunta al massimo numero di depositi possibili sulla traccia – scarta il potere. Non permette di posizionare un deposito aggiuntivo a quello permesso per turno (uno solo)."
    },
    {
      "sym": "12",
      "name": "ORO CHE LUCCICA",
      "value": 1,
      "desc": "Ogni volta che si costruisce sulle M invece di pagare -1$N, la famiglia guadagna +2$N; nel caso di MM, invece di pagare -2$N, guadagna +1$N."
    },
    {
      "sym": "13",
      "name": "QUELLA E’ MIA!",
      "value": 2,
      "desc": "Prenota un posto libero di una traccia stazione (ovunque in mappa, anche se non raggiungibile), che rimane aperta per la corsa di tutte le famiglie. La famiglia che ha prenotato la stazione può piazzare un proprio deposito dove riservato, solo se arriva lì con un percorso (corsa infinita); solo in questo caso il potere si esaurisce e si scarta. Se la famiglia che ha riservato il posto, ha terminato i propri depositi, il posto rimane comunque riservato (aperto per tutte le corse). VIETATO prenotare l’unico spazio RISERVATO per la HOME di una famiglia non ancora operativa."
    },
    {
      "sym": "14",
      "name": "LAVORI IN CORSO",
      "value": 2,
      "desc": "Gli scavi durano un po’ più del previsto: posiziona il token dei lavori in corso in un posto libero di una traccia stazione – HOME o Y – ovunque in mappa, (anche se non raggiungibile), e scarta il potere. Quella stazione non potrà mai essere occupata con un deposito (es. in figura, la traccia risulta “impassabile”; con la sostituzione in traccia verde sarà possibile aprire di nuovo il percorso). VIETATO bloccare l’unico spazio RISERVATO della HOME di una famiglia non ancora operativa."
    },
    {
      "sym": "15",
      "name": "GRANO",
      "value": 2,
      "desc": "Scarta il potere e seleziona una traccia con un proprio deposito (es le giraffe hanno un deposito sulla tessera #14), posizionaci sopra il GRANO; ogni corsa della famiglia con questo potere, quando passa o termina nel deposito con il GRANO, raccoglierà +30 Noci (nell’esempio 30+30 = 60)."
    },
    {
      "sym": "16",
      "name": "DUE BORRACCE",
      "value": 2,
      "desc": "La famiglia può scegliere di non raccogliere le O in tesoreria, ma di raddoppiare il loro valore (contare +20 invece che +10) per tutte le O percorse con tutti i suoi scoiattoli durante la corsa. La famiglia prenderà 0$N indipendentemente da quante O percorre (al primo utilizzo scarta una Borraccia, al secondo utilizzo scarta Borraccia e potere). VIETATO l’utilizzo combinato con la STRIZZATA."
    },
    {
      "sym": "17",
      "name": "UNA STRIZZATA",
      "value": 3,
      "desc": "Gli scoiattoli si bagnano i vestiti, e strizzandoli si trova altra acqua. La famiglia prende ulteriori 3$N se almeno uno scoiattolo percorre una O. VIETATO l’utilizzo combinato con la BORRACCIA."
    },
    {
      "sym": "18",
      "name": "BENDA",
      "value": 2,
      "desc": "Uno scoiattolo non ci vede, e continua a correre anche se pensionato, ma inciampa sempre e fa una corsa con solo un deposito (corre come se fosse un 1S). Lo scoiattolo con la BENDA non può essere venduto. Finché lo scoiattolo ha la benda, la famiglia mantiene il potere attivo; in ogni momento può decidere di rimuovere la benda e cestinare lo scoiattolo – scartando il potere. La famiglia non può acquistare scoiattoli, a meno di cestinare la BENDA. Il potere si può assegnare in qualsiasi momento (anche se non è il turno operativo della famiglia – ad es. quando un’altra famiglia acquista uno scoiattolo che cambia la FASE), ma in questo caso il giocatore che offre la BENDA non riceverà alcun compenso. È possibile assegnare la BENDA al 4S o 3S LUNGO."
    },
    {
      "sym": "19",
      "name": "ALI",
      "value": 2,
      "desc": "Solo durante la corsa, uno scoiattolo a piacere può saltare una traccia impassabile (tutte le tracce stazioni occupate da depositi di altre famiglie), senza però conteggiare il valore della provvista della stazione. Non può essere utilizzato per saltare una traccia stazione con un proprio deposito, o con uno spazio libero. Una stazione con un solo spazio, bloccato da LAVORI IN CORSO, non può essere saltata."
    },
    {
      "sym": "20",
      "name": "BASTA UN POCO DI ZUCCHERO",
      "value": 3,
      "desc": "Uno scoiattolo a piacere corre una fermata in più (es. un 2S corre come un 3S, un 3S corre come un 4S...) – non è applicabile agli scoiattoli 4J o 2J. VIETATO utilizzo con lo scoiattolo con la BENDA."
    }
  ],
  "corporations": [],
  "hexes": {},
  "trains": [
    {
      "name": "2S",
      "distance": 2,
      "price": 7,
      "rusts_on": "4S",
      "num": 1
    },
    {
      "name": "3S",
      "distance": 3,
      "price": 12,
      "rusts_on": "5S",
      "num": 4
    },
    {
      "name": "4S",
      "distance": 4,
      "price": 20,
      "rusts_on": "4J/2J",
      "num": 3
    },
    {
      "name": "5S",
      "distance": 5,
      "price": 30,
      "num": 2
    },
    {
      "name": "4J",
      "distance": 4,
      "price": 47,
      "num": 20
    },
    {
      "name": "2J",
      "distance": 2,
      "price": 37,
      "num": 20,
      "available_on": "4J"
    }
  ],
  "phases": [
    {
      "name": "2S",
      "train_limit": 4,
      "tiles": [
        "yellow"
      ],
      "status": [
        "can_buy_companies"
      ],
      "operating_rounds": 2
    },
    {
      "name": "3S",
      "on": "3S",
      "train_limit": 3,
      "tiles": [
        "yellow",
        "green"
      ],
      "status": [
        "can_buy_companies"
      ],
      "operating_rounds": 2
    },
    {
      "name": "4S",
      "on": "4S",
      "train_limit": 3,
      "tiles": [
        "yellow",
        "green"
      ],
      "status": [
        "can_buy_companies"
      ],
      "operating_rounds": 2
    },
    {
      "name": "5S",
      "on": "5S",
      "train_limit": 2,
      "tiles": [
        "yellow",
        "green",
        "brown"
      ],
      "operating_rounds": 2
    },
    {
      "name": "4J/2J",
      "on": "4J",
      "train_limit": 2,
      "tiles": [
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

        JSON_MAP_SMALL = <<-'DATA'
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
  }
}
        DATA

        JSON_MAP_LARGE = <<-'DATA'
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
  }
}
        DATA

        JSON_MAP_A = <<-'DATA'
{
  "corporations": [
    {
      "sym": "GIRAFFES",
      "float_percent": 40,
      "name": "GIRAFFES",
      "logo": "18_zoo/giraffe",
      "shares": [
        40,
        20,
        20,
        20
      ],
      "max_ownership_percent": 120,
      "always_market_price": true,
      "tokens": [
        0,
        2
      ],
      "coordinates": "J9",
      "color": "#fff793"
    },
    {
      "sym": "POLAR BEARS",
      "float_percent": 40,
      "name": "POLAR BEARS",
      "logo": "18_zoo/polar-bear",
      "shares": [
        40,
        20,
        20,
        20
      ],
      "max_ownership_percent": 120,
      "always_market_price": true,
      "tokens": [
        0,
        2,
        4,
        4
      ],
      "coordinates": "M10",
      "color": "#efebeb"
    },
    {
      "sym": "PENGUINS",
      "float_percent": 40,
      "name": "PENGUINS",
      "logo": "18_zoo/penguin",
      "shares": [
        40,
        20,
        20,
        20
      ],
      "max_ownership_percent": 120,
      "always_market_price": true,
      "tokens": [
        0,
        2,
        4,
        4
      ],
      "coordinates": "J17",
      "color": "#55b7b7"
    },
    {
      "sym": "LIONS",
      "float_percent": 40,
      "name": "LIONS",
      "logo": "18_zoo/lion",
      "shares": [
        40,
        20,
        20,
        20
      ],
      "max_ownership_percent": 120,
      "always_market_price": true,
      "tokens": [
        0,
        2,
        4
      ],
      "coordinates": "D15",
      "color": "#df251a"
    },
    {
      "sym": "TIGERS",
      "float_percent": 40,
      "name": "TIGERS",
      "logo": "18_zoo/tiger",
      "shares": [
        40,
        20,
        20,
        20
      ],
      "max_ownership_percent": 120,
      "always_market_price": true,
      "tokens": [
        0,
        2
      ],
      "coordinates": "G14",
      "color": "#ffa023"
    }
  ],
  "locationNames": {
    "B11": "O",
    "B13": "O",
    "E18": "O",
    "G10": "O",
    "H9": "O",
    "H11": "O",
    "I2": "O",
    "K14": "O",
    "M12": "O",
    "M14": "O",
    "D11": "MM",
    "E10": "MM",
    "F17": "MM",
    "G18": "MM",
    "J3": "MM",
    "K18": "MM",
    "M16": "MM",
    "C12": "M",
    "H15": "M",
    "I14": "M",
    "D17": "M"
  },
  "hexes": {
    "gray": {
      "": [
        "B9",
        "C8",
        "J5",
        "L13"
      ],
      "path=a:0,b:5": [
        "A10"
      ],
      "path=a:3,b:5": [
        "A12"
      ],
      "path=a:0,b:3": [
        "F9"
      ],
      "offboard=revenue:0,hide:1;path=a:0,b:_0;path=a:4,b:_0": [
        "D7"
      ],
      "offboard=revenue:0,hide:1;path=a:3,b:_0": [
        "F21"
      ],
      "path=a:1,b:4,track:narrow;path=a:3,b:5": [
        "G16"
      ],
      "path=a:2,b:3": [
        "G20"
      ],
      "junction;path=a:0,b:_0;path=a:2,b:_0;path=a:4,b:_0": [
        "H3"
      ],
      "offboard=revenue:0,hide:1;path=a:1,b:_0;path=a:0,b:0": [
        "H13"
      ],
      "path=a:4,b:0": [
        "J7"
      ],
      "path=a:2,b:4": [
        "J19"
      ],
      "path=a:1,b:3;path=a:3,b:5": [
        "K6"
      ],
      "path=a:4,b:0;path=a:4,b:1": [
        "L15"
      ],
      "path=a:2,b:5": [
        "L7"
      ],
      "path=a:0,b:2": [
        "M8"
      ],
      "offboard=revenue:0,hide:1;path=a:5,b:_0": [
        "L9"
      ],
      "offboard=revenue:0,hide:1;path=a:1,b:_0": [
        "K8",
        "L3",
        "N9"
      ],
      "offboard=revenue:0,hide:1;path=a:2,b:_0": [
        "I6",
        "K10"
      ]
    },
    "red": {
      "offboard=revenue:yellow_30|brown_60;path=a:3,b:_0;path=a:4,b:_0;label=R": [
        "B17"
      ],
      "offboard=revenue:yellow_30|brown_60;path=a:2,b:_0;label=R": [
        "L5",
        "M18"
      ],
      "offboard=revenue:yellow_30|brown_60;path=a:4,b:_0;label=R": [
        "E8"
      ],
      "offboard=revenue:yellow_30|brown_60;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=R": [
        "H19"
      ]
    },
    "white": {
      "": [
        "I4",
        "H5",
        "F7",
        "H7",
        "G8",
        "I8",
        "C10",
        "I10",
        "F11",
        "J11",
        "L11",
        "E12",
        "G12",
        "I12",
        "K12",
        "D13",
        "F13",
        "J13",
        "C14",
        "E14",
        "B15",
        "F15",
        "C16",
        "E16",
        "I16",
        "K16",
        "H17",
        "L17",
        "I18"
      ],
      "city=revenue:0,slots:1": [
        "J9",
        "M10",
        "J17",
        "D15",
        "G14"
      ],
      "upgrade=cost:0,terrain:water": [
        "B11",
        "B13",
        "E18",
        "G10",
        "H9",
        "H11",
        "I2",
        "K14",
        "M12",
        "M14"
      ],
      "upgrade=cost:2,terrain:mountain": [
        "D11",
        "E10",
        "F17",
        "G18",
        "J3",
        "K18",
        "M16"
      ],
      "upgrade=cost:1,terrain:mountain": [
        "C12",
        "H15",
        "I14",
        "D17"
      ],
      "label=Y;city=revenue:yellow_30|green_40|brown_50,slots:1;offboard=revenue:yellow_20|brown_40,hide:1": [
        "D9",
        "F19",
        "J15",
        "K4"
      ]
    }
  }
}
        DATA

        JSON_MAP_B = <<-'DATA'
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
  "corporations":[],
  "hexes":{}
}
        DATA

        JSON_MAP_C = <<-'DATA'
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
  "corporations":[],
  "hexes":{}
}
        DATA

        JSON_MAP_D = <<-'DATA'
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
  "corporations":[],
  "hexes":{}
}
        DATA

        JSON_MAP_E = <<-'DATA'
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
  "corporations":[],
  "hexes":{}
}
        DATA

        JSON_MAP_F = <<-'DATA'
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
  "corporations":[],
  "hexes":{}
}
        DATA
      end
    end
  end
end

# rubocop:enable Lint/RedundantCopDisableDirective, Layout/LineLength, Layout/HeredocIndentation
