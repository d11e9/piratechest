{_, $, Backbone, Marionette, nw } = require( '../common.coffee' )

web3 = require 'web3'
path = require 'path'
process = require 'child_process'

Logger = require './Logger.coffee'
log = new Logger( verbose: false )

LODESTONE_REQUEST_TOPIC = "lodestone_search"
LODESTONE_LOAD_TIMEOUT = 10 * 1000
LOCAL_GETH_OPTIONS = ['--shh','--networkid','123456','--rpc','console']


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
            log.info( resp )
            @trigger( 'result', resp.payload[0] )

class module.exports.Lodestone
    constructor: ({@host, @port, @magnetCollection, @localNode, connect}) ->
        endpoint = "http://#{ @host }:#{ @port }"
        log.info "Lodestone Ethererum RPC Node endpoint: ", endpoint
        return unless connect
        try
            httpProvider = new web3.providers.HttpProvider( endpoint )
            web3.setProvider( httpProvider )
            web3.eth.blockNumber # to test
            @_setup()
        catch error
            log.error "LODESTONE: Failed to connect to Ethereum RPC node.", error
            @_runLocalGeth() if @localNode
            
    _runLocalGeth: ->
        connected = false
        log.info "LODESTONE: starting local geth instance..."
        binPath = path.join( __dirname , "../../bin/geth.exe" )
        log.info binPath
        @geth = process.spawn( binPath, LOCAL_GETH_OPTIONS )
        log.info @geth
        @geth.stderr.on 'data', (d) =>
            log.info "LODESTONE: Geth: ", d.toString()
            unless connected
                try
                    httpProvider = new web3.providers.HttpProvider( "http://localhost:8545" )
                    web3.setProvider( httpProvider )
                    web3.eth.blockNumber
                    connected = true
                    @_setup()
                catch e
                    log.error "LODESTONE: Error: ", e
        @geth.stdout.on 'data', (d) -> log.info( "LODESTONE Geth: ", d.toString() )
        @geth.on 'close', (code) -> log.error( "LODESTONE: Geth Process Exited with code: ", code)

    _setup: ->
        @searches = []
        @_listenForSearches()
        @isReady = true

    _listenForSearches: ->
        @filter = web3.shh.filter( topics: [ LODESTONE_REQUEST_TOPIC ] )
        @filter.watch (err, resp) =>
            search = resp.payload[0]
            log.info( "Incomming search: ", search ) unless err
            log.error( err ) if err
            @magnetCollection.search( search ).each (magnet) ->
                if magnet.get('searchscore') > 0.5
                    log.info "Responding to search with result: ", magnet
                    web3.shh.post
                        topics: [search]
                        ttl: 100
                        priority: 1000
                        payload: [ magnet.get('infoHash') ]

    newSearch: (input) ->
        search = new LodestoneSearch( input: input )
        @searches.push( search )
        search

    stopSearches: ->
        search.filter.stopListening() for search in @searches

    ready: (cb) =>
        interval = 100
        timeout = 0
        wait = =>
            timeout += interval
            setTimeout (=>
                log.info "LODESTONE: Waiting..."
                if @isReady
                    log.info "LODESTONE: Ready"
                    cb(null, 200)
                else if timeout >= LODESTONE_LOAD_TIMEOUT
                    cb( new Error("Lodestone load timeout exceeded!"), 500 )
                else
                    wait()
            ), interval
        wait()


