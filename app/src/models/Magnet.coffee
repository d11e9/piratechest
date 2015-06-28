{_, $, Backbone, Marionette, nw } = require( '../common.coffee' )
 
hashcash = window.hc = require( 'hashcashgen')
magnetUri = require( 'magnet-uri' )
parseTorrent = require( 'parse-torrent' )

Logger = require './Logger.coffee'
log = new Logger( verbose: true )

class module.exports.Magnet extends Backbone.Model

    initialize: ({infoHash, favorite, dn}) ->
        log.info "Creating Magnet:", arguments
        @set( 'id', infoHash )
        @set( 'infoHash', infoHash )
        @set( 'favorite', favorite )
        @set( 'dn', dn )
        @torrent = window.app.client.add( @get('id'), verify: true )
        @listenTo( @torrent, 'metadata', @_updateMetadata )
        @listenTo( @torrent.swarm, 'wire', @_updateStatus )
        @listenTo( this, 'change:dn change:favorite', @save )
        @torrent.swarm.pause() if @get('dn')
        @download = false

    togglePauseResume: =>
        if @torrent.swarm._paused
            console.log( "Resuming" )
            @download = true
            @torrent.swarm.resume()
        else
            @download = false
            console.log( "Pausing" )
            @torrent.swarm.pause()
        @trigger('updateStatus')

    sync: (method, model, options) ->
        @collection?.store.sync( method, model, options ) if @collection?.store

    _updateStatus: =>
        #log.info "Swarm wire event:", @torrent

        @trigger('updateStatus')

    _updateMetadata: =>
        @set( 'dn', @torrent.name ) unless @get( 'dn' )
        log.info "Updating Magnet from torrent metadata:", @torrent

        # FIXME: Destroying this torrent as soon as we have metadata
        # this may not be the best way to prevent downloading
        # when all we want is the metadata (by default at least)
        # @torrent.swarm?.pause?()        
        @torrent.swarm.pause() unless @download


    @fromTorrent: (torrent) ->
        log.info "Magnet from torrent: ", torrent
        new Magnet
            infoHash: torrent.infoHash

    @fromUri: (uri) =>
        log.info "Magnet from uri: ", uri
        torrent = null
        try
            torrent = parseTorrent( uri )
        catch err
            log.error "Unable to parse magnet uri: ", uri
            return undefined
        @fromTorrent( torrent )