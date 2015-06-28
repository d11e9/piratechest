{_, $, Backbone, Marionette } = require( '../common.coffee' )

class module.exports.DetailsView extends Marionette.ItemView
    className: 'details-view'
    template: _.template """
        <div class="overlay">
            <div class="content">
            <div class="close">
                <i class="icon-remove"></i>
            </div>
            <p>Magnet Details</p>
            <ul>
                <li class="pause-resume">Pause/Resume</li>
                <li class="delete">Delete</li>
            </ul>
            <ul>
                <li><strong>Title:</strong> <%- dn %></li>
                <li><strong>Info Hash:</strong> <%- infoHash %></li>
                <li><strong>Favorite:</strong> <%- favorite %></li>
                <li><strong>Status:</strong> <%- status ? status : 'unknown' %></li>                
                <li>
                    <a class="uri" href="<%- uri %>"><%- uri %></a>
                </li>
                
            </ul>
        </div></div>
    """
    events:
        'click .close': 'handleClose'
        'click .pause-resume': 'handlePauseResume'
        'click .delete': '_deleteMagnet'

    serializeData: ->
        uri: @model.torrent.magnetURI
        infoHash: @model.get('infoHash')
        dn: @model.get('dn')
        favorite: @model.get('favorite')
        status: @model.get('status')

    initialize: ->
        @listenTo @model, 'change', @render

    onShow: ->
        console.log( "Showing details for: ", @model)
        window.Mousetrap.bind('del', @_deleteMagnet )
        @_updateDetails()

    _updateDetails: ->
        console.log @model
        @model.torrent?.discovery?.tracker?.scrape?()
        @model.torrent?.discovery?.tracker?.on 'scrape', (data) =>
            console.log "Got Scrape event for torrent: #{ @model.torrent.infoHash }"
            @model.set('peers', data.complete )

    _deleteMagnet: =>
        console.log( "Deleting magnet: ", @model)
        @model.torrent.remove()
        @model.destroy()
        @handleClose()

    handlePauseResume: ->
        @model.togglePauseResume()
        console.log( @model.torrent )

    handleClose: ->
        window.Mousetrap.reset()
        @trigger( 'close' )