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
                <li><strong>Title:</strong> <%- dn %></li>
                <li><strong>Info Hash:</strong> <%- infoHash %></li>
                <li><strong>Favorite:</strong> <%- favorite %></li>
                <li><strong>Status:</strong> <%- status ? 'ok' : 'unknown' %></li>
                <li><strong>Peers:</strong> <%- peers %></li>
                <li>
                    <a class="uri" href="<%- uri %>"><%- uri %></a>
                </li>
                <li>
                    <strong>Tags:</strong>
                    <ol>
                        <% for ( tag in allTags ) { %>
                            <li><%- tags[tag] %></li>
                        <% } %>
                    </ol>
                </li>
            </ul>
        </div></div>
    """
    events:
    	'click .close': 'handleClose'

    templateHelpers: ->
        allTags: -> @model.getTags()

    initialize: ->
        @listenTo @model, 'change', @render

    handleClose: ->
    	@trigger( 'close' )