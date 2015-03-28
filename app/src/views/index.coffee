
{_, $, Backbone, Marionette } = require( '../common.coffee' )
{ nw, win } = window.nwin

{ Magnet } = require '../models/models.coffee'

{ TitlebarView  } = require './TitlebarView.coffee'

{ MenuView  } = require './MenuView.coffee'
{ LodestoneView  } = require './LodestoneView.coffee'
{ CardsView  } = require './CardsView.coffee'
{ SettingsView  } = require './SettingsView.coffee'

{ MagnetCollectionView  } = require './MagnetCollectionView.coffee'
{ DetailsView  } = require './DetailsView.coffee'



class BodyView extends Marionette.LayoutView
    className: 'body-view'
    template: _.template """
        <form class="add-new">
            Add new magnet <input placeholder="infoHash" type="text" class="infoHash"/> <button><i class="icon-plus"></i></button>
        </form>
        <div class="magnets-region"></div>
        <div class="details-region"></div>
    """
    ui:
        input: '.add-new input'
    
    regions:
        magnets: '.magnets-region'
        details: '.details-region'

    events:
        'submit form': 'handleAddMagnet'
        'click .add-new button': 'handleAddMagnet' 
    
    initialize: ({@collection}) ->
        @collectionView = new MagnetCollectionView( collection: @collection )
        @listenTo @collectionView, 'show:details', @handleShowDetails

    handleAddMagnet: (ev) ->
        ev.preventDefault()
        magnet = new Magnet
            infoHash: @ui.input.val()
            favorite: false
        @collection.add( magnet )
        @ui.input.val( '' )

    onShow: ->
        @magnets.show( @collectionView )

    handleShowDetails: (magnet) ->
        detailsView = new DetailsView( model: magnet )
        @details.show( detailsView )
        detailsView.on 'close', => @details.empty()

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
        <div class="body-region"></div>
    """
    regions:
        header: '.header'
        menu: '.menu'
        body: '.body-region'
        overlay: '.overlay'

    initialize: ({@collection}) ->
        @menuView = new MenuView()
        @listenTo @menuView, 'show:menuItem', @handleShowMenuItem

    onShow: ->
        @header.show( new TitlebarView() )
        @menu.show( @menuView )
        @handleShowMenuItem( 'collection' )

    handleShowMenuItem: (item) ->
        switch item
            when 'collection' then @body.show( new BodyView( collection: @collection ) )
            when 'search' then @body.show( new LodestoneView() )
            when 'cards' then @body.show( new CardsView() )
            when 'settings' then @body.show( new SettingsView() )
            else @body.empty()

    showOverlay: (view) ->
        view.on 'close', => @overlay.empty()
        @overlay.show( view )


module.exports = { AppView, LoadingView, OverlayView }
