
{_, $, Backbone, Marionette } = require( '../common.coffee' )
{ nw, win } = window.nwin

Logger = require '../models/Logger.coffee'
log = new Logger( verbose: false )


class MagnetView extends Marionette.ItemView
    className: 'magnet-view'
    template: _.template """
        <div class="magnet-view-inner">
            <div class="progress" style="width: <%- progress %>%;"></div>
            <span class="title" data-title="Progress: <%- progress %>%;"><%- title %></span>
            <div class="actions">
                <i data-title="Toggle Favorite" class="icon-heart<%= favorite ? '' : '-empty' %> favorite <%= favorite ? 'fav' : '' %>"></i>
                <i data-title="<%- status.info %>" class="status <%- status.class %>"></i>
                <a class="magnet-link" href="<%- uri %>"><i data-title="Magnet Link" class="icon-magnet"></i></a>
            </div>
        </div>
    """
    events:
        'click a': 'handleMagnetClick'
        'click .favorite': 'toggleFav'
        'click .save': 'handleSave'
        'click .title': 'handleShowDetails'
        'click .status': 'handlePauseResume'

    serializeData: ->
        title: @model.get('dn') or @model.get( 'infoHash' )
        favorite: @model.get( 'favorite' )
        status: @_getStatus()
        uri: @model.torrent.magnetURI
        progress: @model.torrent.progress

    initialize: ->
        @listenTo @model, 'change', @render
        @listenTo @model, 'updateStatus', @render

    toggleFav: ->
        @model.set( 'favorite', !@model.get( 'favorite') )

    _getStatus: ->
        peers = @model.torrent.swarm.numPeers
        paused = @model.torrent.swarm._paused
        if paused
            class: 'icon-download'
            info: 'Resume'
        else if peers is 0
            class: 'icon-spinner'
            info: 'Fetching metadata'
        else if 5 > peers >= 1
            class: 'icon-circle red'
            info: 'Peers: ' + peers
        else if 25 > peers >= 5
            class: 'icon-circle orange'
            info: 'Peers: ' + peers
        else if peers >= 25
            class: 'icon-circle green'
            info: 'Peers: ' + peers
        else
            class: 'icon-circle'
            info: 'Unknown status'

    handleMagnetClick: (ev) =>
        ev.preventDefault()
        nw.Shell.openExternal( @model.torrent.magnetURI )
        false

    handlePauseResume: ->
        @model.togglePauseResume()

    handleSave: ->
        @trigger('save:magnet', @model )

    handleShowDetails: ->
        @trigger( 'show:details', @model )

class module.exports.MagnetCollectionView extends Marionette.CollectionView
    childView: MagnetView
    childEvents:
        'show:details': 'handleShowDetails'
        'save:magnet': 'handleSaveMagnet'

    handleShowDetails: (view, magnet) ->
        @trigger( 'show:details', magnet )

    handleSaveMagnet: (view, magnet)->
        log.info "SAVE magnet: #{ magnet.get('infoHash') }"
        @trigger( 'save:magnet', magnet )
