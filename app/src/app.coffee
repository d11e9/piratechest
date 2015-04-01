fs = require 'fs'
WebTorrent = require 'webtorrent'


{_, $, Backbone, Marionette, nw, win, localStorage } = require './common.coffee'
{ AppView } = require './views/AppView.coffee'
{ LoadingView } = require './views/LoadingView.coffee'
{ IntroView } = require './views/IntroView.coffee'
{ ContentsView } = require './views/ContentsView.coffee'


{ MagnetCollection, Magnet } = require './models/models.coffee'

# { Database } = require './Database.coffee'
# db = new Database
#     'magnets': Magnet
# Backbone.sync = db.customSync

nativeMenuBar = new nw.Menu( type: "menubar" )
nativeMenuBar.createMacBuiltin("Pirate Chest") if process.platform is 'darwin'
win.menu = nativeMenuBar;

CONFIG = require( '../config.json')
console.log 'CONFIG: ', CONFIG

client = new WebTorrent
    tracker: CONFIG?.flags?.runTracker

client.on 'error', (error) ->
    console.error "Webtorrent Error:", error

magnetCollection = new MagnetCollection( null, torrentClient: client )

if CONFIG?.flags?.clearLocalStorageOnStartup
    localStorage.clear()

if CONFIG?.flags?.showInspectorOnStartup
    win.showDevTools()

if CONFIG?.flags?.loadFromLocalstorage
    magnetCollection.fetch()


window.app = app = {}

if CONFIG?.flags?.getPeersFromSeed
    # Use The Map, to find bootstrap/seed peers.
    client.seed "#{ __dirname }/../images/map.svg", { name: 'PiratechestSeedMap.svg', comment: 'This map is designed to be seeded as a torrent by the piratechest application in order to bootstrap peer discovery.' }, (torrent) ->
        console.log "Seeding the map. Stored at: window.seedMap"
        window.seedMap = app.seedMap = torrent
        magnetCollection.add Magnet.fromTorrent( torrent )
        app.seeds = torrent.swarm._peers
        torrent.swarm.resume()

$ ->
    appRegion = new Marionette.Region( el: $('body').get(0) )
    appRegion.show( new LoadingView() )
    # TODO: Actually load stuff not just setTimeout
    appView = new AppView( config: CONFIG, collection: magnetCollection, torrentClient: client )
    setTimeout ( ->
        appRegion.show( appView )
        introView = new IntroView()
        appView.showOverlay( introView ) unless localStorage.introShown
        introView.on 'open', ->
            appView.showOverlay( new ContentsView() )
            
    ), 1000
    win.show()

    # test magnet TODO: Remove this.
    setTimeout ( ->

        magnetCollection.add new Magnet
            infoHash: '546cf15f724d19c4319cc17b179d7e035f89c1f4'
            favorite: false

        magnetCollection.add new Magnet
            infoHash: '81d8ef3729a7265d30155c5e7b047312fe473e44'
            favorite: false

        
    ), 3000


