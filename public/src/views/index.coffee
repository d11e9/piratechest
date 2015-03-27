
{_, $, Backbone, Marionette } = require( '../common.coffee' )

{ Magnet } = require '../models/models.coffee'

{ TitlebarView  } = require './TitlebarView.coffee'
{ MenuView  } = require './MenuView.coffee'
{ nw, win } = window.nwin

class MagnetView extends Marionette.ItemView
    className: 'magnet-view'
    template: _.template """
        <i data-title="More Infomation" class="icon-collapse"></i>
        <span class="infoHash"><%- infoHash %></span>
        <i data-title="Toggle Favorite" class="icon-heart favorite <%= favorite ? 'fav' : '' %>"></i>
        <i data-title="Torrent Status" class="icon-circle-blank"></i>
        <a href="magnet:?xt=urn:btih:<%- infoHash %>"><i data-title="Magnet Link" class="icon-magnet"></i></a>
    """
    events:
        'click a': 'handleMagnetClick'
        'click .favorite': 'toggleFav'

    toggleFav: ->
        @model.set( 'favorite', !@model.get( 'favorite') )
        @render()

    getMagnetUri: ->
        "magnet:?xt=urn:btih:#{ @model.get( 'infoHash' ) }"

    handleMagnetClick: (ev) =>
        uri = @getMagnetUri()
        console.log "Opening magnet uri #{ uri } externally."
        nw.Shell.openExternal( uri )

class MagnetCollectionView extends Marionette.CollectionView
    childView: MagnetView

class BodyView extends Marionette.ItemView
    className: 'body-view'
    template: _.template """
        <form class="add-new">
            Add new magnet <input placeholder="infoHash" type="text" class="infoHash"/> <button><i class="icon-plus"></i></button>
        </form>
        <div class="magnets"></div>
    """
    ui:
        magnets: '.magnets'
        input: '.add-new input'

    events:
        'submit form': 'handleAddMagnet'
        'click .add-new button': 'handleAddMagnet' 
    
    initialize: ({@collection}) ->

    handleAddMagnet: (ev) ->
        ev.preventDefault()
        magnet = new Magnet
            infoHash: @ui.input.val()
            favorite: false
        @collection.add( magnet )
        @ui.input.val( '' )

    onShow: =>
        @magnets = new Marionette.Region( el: @ui.magnets.get(0) )
        @magnets.show( new MagnetCollectionView( collection: @collection ) )





class LoadingView extends Marionette.ItemView
    className: 'loading-view'
    template: _.template """
        <img src="images/logo.png" alt="Pirate Chest" />
        <p>Loading...</p>
    """

class OverlayView extends Marionette.ItemView
    className: 'overlay-view'
    template: _.template """
        <div class="overlay">
            <div class="content">
                <h1>Hi</h1>
                <p>I'm an overlay!</p>
            </div>
        </div>
    """
    events:
        'click .overlay': 'handleClickOverlay'
        'click .content': 'handleClickContent'

    handleClickContent: (ev) ->
        ev.preventDefault()
        false

    handleClickOverlay: ->
        @trigger( 'close' )

class AppView extends Marionette.LayoutView
    className: 'app-view'
    template: _.template """
        <div class="header"></div>
        <div class="menu"></div>
        <div class="overlay"></div>
        <div class="body"></div>
    """
    regions:
        header: '.header'
        menu: '.menu'
        body: '.body'
        overlay: '.overlay'

    initialize: ({@collection}) ->
        @menuView = new MenuView()
        @listenTo @menuView, 'show:menuItem', @handleShowMenuItem

    onShow: ->
        @header.show( new TitlebarView() )
        @menu.show( @menuView )
        @body.show( new BodyView( collection: @collection ) )

    handleShowMenuItem: (item) ->
        switch item
            when 'collection' then @body.show( new BodyView( collection: @collection ) )
            else @body.empty()

    showOverlay: (view) ->
        view.on 'close', => @overlay.empty()
        @overlay.show( view )


module.exports = { AppView, LoadingView, OverlayView }

