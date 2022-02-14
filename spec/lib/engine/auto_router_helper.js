// helper javscript used by auto_router_spec.rb
// this script expects to be appended to a script that has
//      let data = { ... };
// which represents the json game data to load
function load_and_run() {
    var engine_module;
    var game_module;
    var autorouter_module;
    $nesting = [];
    $$ = Opal.$r($nesting);

    let status = ""

    function setup() {
        // the game site has a top-level div called "app" that snabberb connects to in the Opal.App.$attach
        //    <div id="app"></div>
        // Without it, something deep in snabberb fails because it's trying to do things with that html element.
        // How to I get a parent html element here?  
        // Or how do I avoid using in snabberb?
        // App is apparently a snabberb component, that's why snabberb.$$attach is being called
        // Maybe the App.$attach just shouldn't be done if not in web page
        // Opal.App.$attach("app", Opal.hash(
        //     "app_route", "/",
        //     "production", false,
        //     "title", Opal.nil,
        //     "pin", Opal.nil,
        //     "games", [],
        //     "user", Opal.nil));
        // return "Opal.App.$attach succeeded" // TEMP

        //Opal.load('engine/game/g_21_moon');
        Opal.load('engine');
        //let game_module = Opal.load('engine/game');

        engine_module = $$('Engine');
        status += "loaded 'engine'; "

        //engine_module.$load();

        //return "LOADED" // TEMP

        // TEMP testing
        //cache = engine_module.$$const_cache;
        //if (cache == null)
        //    return 'engine_module cache is null ';
        //cached = cache[name];
        //return 'engine_module cache has ' + cache.size + ' entries';

        autorouter_module = Opal.$$$(engine_module, 'AutoRouter');
        status += "loaded 'AutoRouter'; "

        //let game_module = Opal.$$$($$('Engine'), 'Game');
        game_module = Opal.$$$(engine_module, 'Game');
        status += "loaded 'Game'; "
    };
    //try {
        setup();
    //}
    //catch (e)
    //{
    //    return "ERROR: " + e.message + " " + status;
    //}

    //return status

    var game;
    function load_game() {
        game = game_module.$load(data);
        status += 'game.$load(data); '
    };
    load_game();

    return status

    var router;
    var routes;
    function calc_routes() {
        router = autorouter_module.$new(game);
        const args = Opal.hash("routes", null, "path_timeout", 300, "route_timeout", 30);
        routes = router.$compute(game.$current_entity(), args);
    };
    calc_routes();

    const revenue_string = game.$submit_revenue_str(routes);
    return revenue_string;
}
load_and_run()