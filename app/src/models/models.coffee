{_, $, Backbone, Marionette, nw } = require( '../common.coffee' )
 
hashcash = window.hc = require( 'hashcashgen')
magnetUri = require( 'magnet-uri' )
parseTorrent = require( 'parse-torrent' )


class Magnet extends Backbone.Model

    initialize: ({infoHash, favorite, dn, tr, tags}) ->
        @set 'infoHash', infoHash
        @set 'favorite', if favorite then true else false
        @set 'status', false
        @set 'dn', dn or false
        @set 'tr', tr
        @set 'peers', 0
        @set 'uri', @getUri()
        @set 'tags', []
        @listenTo @, 'change', -> @save()

    getUri: => magnetUri.encode
        infoHash: @get('infoHash')

    sync: (method, model, options) ->
        @collection?.store.sync( method, model, options ) if @collection?.store

    getTags: ->
        name = @get( 'dn' )
        tags = @get( 'tags' )
        tags.concat( name?.split?( /\W+/ ) or [] )

    updateMetadata: (torrent) =>
        @torrent ?= torrent
        console.log "Updating torrent metadata:", arguments
        @set( 'dn', torrent.dn or torrent.name or false )
        @set( 'peers', torrent?.swarm?.numPeers or 0 )
        @set( 'tr', torrent.tr )
        @set( 'status', true )
        console.log('updated magnet', @, torrent)
        # FIXME: Destroying this torrent as soon as we have metadata
        # this may not be the best way to prevent downloading
        # when all we want is the metadata (by default at least)
        @trigger('change')
        @torrent.destroy?()
        torrent.destroy?()

    @fromTorrent: (torrent) ->
        new Magnet
            infoHash: torrent.infoHash
            dn: torrent.dn or false
            tr: torrent.tr

    @fromUri: (uri) =>
        torrent = null
        try
            torrent = parseTorrent( uri )
        catch err
            console.error "Unable to parse magnet uri: ", uri
            return undefined
        @fromTorrent( torrent )


class MagnetCollection extends Backbone.Collection

    model: Magnet
    initialize: (models, {@torrentClient, @store} = {}) ->
        @listenTo @, 'add', @_handleAdd

    _handleAdd: (model, collection, options) ->
        collection.getTorrentData(model)

    sync: (method, model, options) ->
        @store.sync( method, model, options ) if @store

    getTorrentData: (model) =>
        return unless @torrentClient
        torrent = @torrentClient.get( model.get('infoHash') )
        unless torrent
            torrent = @torrentClient.add( model.getUri(), model.updateMetadata )
        else
            model.updateMetadata( torrent )

    add: (model) =>
        console.log "Adding to MagnetCollection", model
        hash = model.get?( 'infoHash')
        return false unless hash
        try
            parsedTorrent = (hash && hash.parsedTorrent) || parseTorrent(hash)
        catch err
            console.error( "Invalid torrent cannot add. " )
            console.log 'couldnt add:', model.get( 'hash' )
            return false

        isDupe = @any (m) -> m.get('infoHash') is hash
        console.log( "Added magnet id a DUPE? #{ isDupe }" )
        return false if isDupe

        @getTorrentData(model)

        # Up to you either return false or throw an exception or silently ignore
        # NOTE: DEFAULT functionality of adding duplicate to collection is to IGNORE and RETURN. Returning false here is unexpected. ALSO, this doesn't support the merge: true flag.
        # Return result of prototype.add to ensure default functionality of .add is maintained. 
        return Backbone.Collection.prototype.add.call( this, model ) 

class Card extends Backbone.Model

    TYPES =
        TEXT: 'text'
        DATA: 'data'

    DEFAULT_TYPE = TYPES.DATA

    initialize: (input) ->
        @set( 'type', input.type or DEFAULT_TYPE )

    @fromInput: (input) =>
        return new Card( input ) if typeof input is 'object'

        try
            data = JSON.parse( input )
            return new Card( data )
        catch err
            console.error err
            if typeof input is 'string'
                return new Card( text: input, type: TYPES.TEXT )
            else
                throw new Error( 'Invalid input for Card Model' )

    getContent: =>
        type = @get( 'type' )
        console.log @
        if type is TYPES.TEXT
            @get('text')
        else
            JSON.stringify( JSON.stringify( @attributes ) )



class CardCollection extends Backbone.Collection
    model: Card
    initialize: ->





module.exports = { Magnet, MagnetCollection, Card, CardCollection }