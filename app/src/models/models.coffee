{_, $, Backbone, Marionette, nw } = require( '../common.coffee' )
 
hashcash = window.hc = require( 'hashcashgen')
magnetUri = require( 'magnet-uri' )
parseTorrent = require( 'parse-torrent' )


class Magnet extends Backbone.Model

    initialize: ({infoHash, favorite, name, dn, tr, tags, torrent}) ->
        @set 'infoHash', infoHash
        @set 'favorite', if favorite then true else false
        @set 'status', false
        @set 'dn', name or dn or ''
        @set 'tr', tr
        @set 'peers', 0
        @set 'uri', @getUri()
        @set 'tags', []
        @updateMetadata( torrent ) if torrent

    getUri: => magnetUri.encode
        infoHash: @get('infoHash')

    sync: (method, model, options) ->
        window.magnetStore.sync( method, model, options )

    getTags: ->
        name = @get( 'dn' )
        tags = @get( 'tags' )
        tags.concat( name?.split?( /\W+/ ) or [] )

    updateMetadata: (torrent) =>
        @torrent ?= torrent
        console.log "Updating torrent metadata:", torrent
        @set( 'dn', torrent.dn or torrent.name or '' )
        @set( 'peers', torrent?.swarm?.numPeers or 0 )
        @set( 'tr', torrent.tr )
        @set( 'status', true )
        # FIXME: Destroying this torrent as soon as we have metadata
        # this may not be the best way to prevent downloading
        # when all we want is the metadata (by default at least)
        @torrent?.swarm?.pause()
        @save()

    @fromTorrent: (torrent) ->
        new Magnet
            infoHash: torrent.infoHash
            dn: torrent.dn
            tr: torrent.tr

    @fromUri: (uri) ->
        torrent = null
        try
            torrent = parseTorrent( uri )
        catch err
            console.error "Unable to parse magnet uri: ", uri
            return new Magnet( infoHash: uri )
        @fromTorrent( torrent )


class MagnetCollection extends Backbone.Collection

    initialize: (models, {torrentClient}) ->
        @torrentClient = torrentClient
        @listenTo @, 'add', @_handleAdd

    _handleAdd:() ->
        console.log '_handleAdd:', arguments

    sync: (method, model, options) ->
        window.magnetStore.sync( method, model, options )

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
        torrent = @torrentClient.get( model.get('infoHash') ) or @torrentClient.add( model.getUri(), model.updateMetadata )
        model.torrent = torrent

        # Up to you either return false or throw an exception or silently ignore
        # NOTE: DEFAULT functionality of adding duplicate to collection is to IGNORE and RETURN. Returning false here is unexpected. ALSO, this doesn't support the merge: true flag.
        # Return result of prototype.add to ensure default functionality of .add is maintained. 
        return if isDupe then false else Backbone.Collection.prototype.add.call( this, model ) 

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