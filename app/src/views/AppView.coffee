
{_, $, Backbone, Marionette, win, nw } = require( '../common.coffee' )


{ TitlebarView  } = require './TitlebarView.coffee'

{ MenuView  } = require './MenuView.coffee'
{ LodestoneView  } = require './LodestoneView.coffee'
{ CardsView  } = require './CardsView.coffee'
{ SettingsView  } = require './SettingsView.coffee'
{ BodyView } = require './BodyView.coffee'
{ RaidsView } = require './RaidsView.coffee'

class module.exports.AppView extends Marionette.LayoutView
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

    initialize: ({@collection, config, @torrentClient}) ->
        @defaultItem = config?.defaultView
        @menuView = new MenuView( { @defaultItem } )
        
        @views = {}
        @views['collection'] = new BodyView
            collection: @collection

        @views['search'] = new LodestoneView
            collection: @collection
            torrentClient: @torrentClient
            config: config

        @views['cards'] = new CardsView()
        @views['settings'] = new SettingsView()
        @views['raids'] = new RaidsView()

    onShow: ->
        @header.show( new TitlebarView() )
        @menu.show( @menuView )
        @listenTo @menuView, 'show:menuItem', @_handleShowMenuItem
        @_handleShowMenuItem( @defaultItem or 'collection' )

    _handleShowMenuItem: (item) ->
        view = @views[item]
        @listenTo view, 'show:overlay', @showOverlay
        console.log "AppView: showing #{ item } view.", view    
        @body.show( view, preventDestroy: true )

    showOverlay: (view) ->
        console.log "Showing overlay: ", view
        @overlay.show( view )
