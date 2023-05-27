function migrate(game, id) {
  if (game.mode !== 'hotseat') {
    console.log(`Skipping "${id}", it does not look like a hotseat game.`);
    return;
  }

  if (game.settings.legacy_seed) {
    console.warn(`"${id}" already has a legacy_seed. Skipping migration.`);
    console.warn(game.settings);
    return;
  }

  // preserve the old seed (which only was used for initial turn order) just in
  // case
  game.settings.legacy_seed = game.settings.seed;

  // set seed to the numerical part of the game ID
  var seed = parseInt(/\d+/.exec(id)[0], 10);
  game.settings.seed = seed;

  // update value saved in localStorage
  localStorage.setItem(id, JSON.stringify(game));

  console.log(`Migrated hotseat game "${id}".`);
}

function migrate_by_id(id) {
  var game = JSON.parse(localStorage.getItem(id));
  migrate(game, id);
}

function migrate_all() {
  for (var i = 0; i < localStorage.length; i++) {
    var id = localStorage.key(i);
    migrate_by_id(id.toString());
  }
}


console.log("Functions migrate(), migrate_by_id(), and migrate_all() have been loaded.");
console.log("To migrate one hotseat game, call migrate_by_id with the hotseat game's ID. For example, type \"migrate_by_id('hs_onvmiaqn_146701')\" and then press enter.");
console.log("To migrate all of your hotseat games, type \"migrate_all()\" and then press enter.")
