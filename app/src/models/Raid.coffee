{_, $, Backbone, Marionette, nw } = require( '../common.coffee' )

http = require 'http'
url = require 'url'

class module.exports.Raid extends Backbone.Model
    initialize: ->
        @updates = []
        @_createServer()
        @_launchBrowser()

    end: ->
        @server.close()

    _createServer: =>
        @server = http.createServer( @_handleRaidUpdates )
        @server.listen(1337, 'localhost')
        console.log('Raid Server running at http://localhost:1337/')

    _launchBrowser: =>
        @win = nw.Window.open 'http://en.wikipedia.org/wiki/Magnet_URI_scheme',
            position: 'center'
            width: 800
            height: 600
            focus: true
            'inject-js-end': './raid.js'
            'new-instance': true
        @_attachWindowListeners()

    _attachWindowListeners: =>
        @win.on 'loaded', -> console.log "Window Loaded"
        @win.on 'close', -> console.log "Window Closed"

    _handleRaidUpdates: (req, res) =>
        res.setHeader('Access-Control-Allow-Origin', '*')
        res.setHeader('Access-Control-Allow-Methods', 'GET')
        res.setHeader('Access-Control-Allow-Headers', 'Content-Type')
        
        url_parts = url.parse( req.url, true )
        query = url_parts.query
        console.log( "Recieved Raid Update from: ", req.headers.referer )
        @updates.push
            uri: query.uri
            host: req.headers.referer
        @trigger( 'updates', @updates )
        
        res.writeHead( 200, {'Content-Type': 'text/plain'} )
        res.end('Arg!!!!')