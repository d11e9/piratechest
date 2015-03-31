{_, $, Backbone, Marionette, nw } = require( '../common.coffee' )
{ Raid } = require '../models/Raid.coffee'

class module.exports.RaidsView extends Marionette.LayoutView
    className: 'raids-view'
    template: _.template """
        <div class="content">
            <img src="images/map.svg" alt="">
            <h1>Raids</h1>
            <p>Start raiding to gather loot.</p>
            <button class="start-raid">Start</button>
            <p>For <strong>Documentation</strong> or to <strong>Report Bugs</strong> you can go to our github repo at: <a href="http://github.com/piratechest/piratechest">http://github.com/piratechest/piratechest</a>.</p>
            <h2>Rumours</h2>
            <p>...</p>
            <h2>Loot</h2>
            <button class="save-loot">Save Loot</button>
            <div class="loot">...</div>
        </div>
    """
    ui:
        loot: '.loot'
        content: '.content'
    events:
        'click a': 'openLink'
        'click .start-raid': '_handleStartRaid'
        'click .save-loot': '_handleSSaveLoot'

    openLink: (ev) ->
        nw.Shell.openExternal( ev.currentTarget.href );
        ev.preventDefault()
        false


    _handleStartRaid: ->
        @raid = new Raid()
        console.log "Started Raid: ", @raid
        @raid.on 'updates', @_handleUpdates

    _handleUpdates: =>
        updates = @raid.updates
        @ui.content.toggleClass( 'found-loot', !!updates.length )
        @ui.loot.html('')
        @ui.loot.append( $('<div/>').html( update.uri ) ) for update in updates
        

        