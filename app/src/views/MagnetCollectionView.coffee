
{_, $, Backbone, Marionette } = require( '../common.coffee' )
{ nw, win } = window.nwin

Logger = require '../models/Logger.coffee'
log = new Logger( verbose: false )


class MagnetView extends Marionette.ItemView
    className: 'magnet-view'
    template: _.template """
        <div class="magnet-view-inner">
            <i data-title="More Infomation" class="details icon-collapse"></i>
            <span class="title"><%- title %></span>
            <i data-title="Toggle Favorite" class="icon-heart<%= favorite ? '' : '-empty' %> favorite <%= favorite ? 'fav' : '' %>"></i>
            <i data-title="Torrent Status" class="status icon-circle <%- status ? 'ok' : '' %>"></i>
            <a class="magnet-link" href="<%- uri %>"><i data-title="Magnet Link" class="icon-magnet"></i></a>
            <i class="save icon-collapse"></i>
        </div>
    """
    events:
        'click a': 'handleMagnetClick'
        'click .favorite': 'toggleFav'
        'click .save': 'handleSave'
        'click .title': 'handleShowDetails'
        'click .details': 'handleShowDetails'

    serializeData: ->
        title: @model.get( 'dn' ) or @model.get( 'infoHash' )
        favorite: @model.get( 'favorite' )
        status: @model.get( 'status' )
        uri: @model.getUri()

    initialize: ->
        @listenTo @model, 'change', @render

    toggleFav: ->
        @model.set( 'favorite', !@model.get( 'favorite') )

    handleMagnetClick: (ev) =>
        ev.preventDefault()
        nw.Shell.openExternal( @model.getUri() )
        false

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
