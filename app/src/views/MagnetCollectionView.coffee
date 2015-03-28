
{_, $, Backbone, Marionette } = require( '../common.coffee' )
{ nw, win } = window.nwin

class MagnetView extends Marionette.ItemView
    className: 'magnet-view'
    template: _.template """
        <i data-title="More Infomation" class="details icon-collapse"></i>
        <span class="title"><%- title || infoHash %></span>
        <i data-title="Toggle Favorite" class="icon-heart favorite <%= favorite ? 'fav' : '' %>"></i>
        <i data-title="Torrent Status" class="status icon-circle <%- status ? 'ok' : '' %>"></i>
        <a href="<%- uri %>"><i data-title="Magnet Link" class="icon-magnet"></i></a>
    """
    events:
        'click a': 'handleMagnetClick'
        'click .favorite': 'toggleFav'
        'click .title': 'handleShowDetails'
        'click .details': 'handleShowDetails'

    initialize: ->
        @listenTo @model, 'change', @render

    toggleFav: ->
        @model.set( 'favorite', !@model.get( 'favorite') )

    handleMagnetClick: (ev) =>
        ev.preventDefault()
        nw.Shell.openExternal( @model.getUri() )
        false

    handleShowDetails: ->
        @trigger( 'show:details', @model )

class module.exports.MagnetCollectionView extends Marionette.CollectionView
    childView: MagnetView
    childEvents:
        'show:details': 'handleShowDetails'

    handleShowDetails: (view, magnet) ->
        @trigger( 'show:details', magnet )