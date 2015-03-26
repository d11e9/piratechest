
{_, $, Backbone, Marionette } = require( '../common.coffee' )
{ TitlebarView  } = require './TitlebarView.coffee'

# gm = require( '../lib/gossip.js')
# hashcash = window.hc = require( 'hashcashgen')


class MagnetView extends Marionette.ItemView
    className: 'magnet'
    template: _.template """
        <span class="infoHash"><%- infoHash %></span><a href="magnet:?xt=urn:btih:<%- infoHash %>"><i class="icon-magnet"></a></i>
    """
    events:
        'click a': 'handleMagnetClick'
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
        @collection.add( infoHash: @ui.input.val() )
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
        <div class="overlay"></div>
        <div class="body"></div>
    """
    regions:
        header: '.header'
        body: '.body'
        overlay: '.overlay'

    initialize: ({@collection}) ->
    onShow: ->
        @header.show( new TitlebarView() )
        @body.show( new BodyView( collection: @collection ) )

        overlay = new OverlayView()
        overlay.on 'close', => @overlay.empty()
        @overlay.show( overlay )


module.exports = { AppView, LoadingView }