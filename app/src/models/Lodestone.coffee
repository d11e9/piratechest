{_, $, Backbone, Marionette, nw } = require( '../common.coffee' )

web3 = require 'web3'

LODESTONE_REQUEST_TOPIC = "lodestone_search"


class LodestoneSearch extends Backbone.Model
    initialize: ({input}) ->
        @set( 'input', input )
        @_createFilter()
        @_sendSearch()

    _sendSearch: ->
        web3.shh.post
            topics: [LODESTONE_REQUEST_TOPIC]
            ttl: 100
            priority: 1000
            payload: [ @get( 'input' ) ]

    _createFilter: ->
        @filter = web3.shh.filter
            topics: [ @get( 'input' ) ]
        @filter.watch( @_handleFilterResponse )

    _handleFilterResponse: (err, resp) =>
        if err
            @filter.stopListening()
        else
            console.log( resp )

class module.exports.Lodestone
    constructor: ({@host, @port})->
        endpoint = "http://#{ @host }:#{ @port }"
        console.log "Lodestone Ethererum RPC Node endpoint: ", endpoint
        httpProvider = new web3.providers.HttpProvider( endpoint )
        web3.setProvider( httpProvider )
        @searches = []
        @_listenForSearches()

    _listenForSearches: ->
        @filter = web3.shh.filter( topics: [ LODESTONE_REQUEST_TOPIC ] )
        @filter.watch (err, resp) ->
            console.log( "Incomming searches: ", resp ) unless err
            console.error( err ) if err

    newSearch: (input) ->
        search = new LodestoneSearch( input: input )
        @searches.push( search )
        search

    stopSearches: ->
        search.filter.stopListening() for search in @searches


