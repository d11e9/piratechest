{_, $, Backbone, Marionette } = require( '../common.coffee' )

class module.exports.DetailsView extends Marionette.ItemView
    className: 'details-view'
    template: _.template """
    	<div class="close">
    		<i class="icon-remove"></i>
    	</div>
        <p>Magnet Details</p>
        <ul>
        	<li>Info Hash: <%- infoHash %></li>
        	<li>Favorite: <%- favorite %></li>
        	<li>Status: 34/999</li>
            <li>
                <a class="uri" href="<%- uri %>"><%- uri %></a>
            </li>
        	<li>
        		Tags:
        		<ol>
        			<li>Test</li>
        			<li>Ubuntu</li>
        		</ol>
        	</li>
        </ul>
    """
    events:
    	'click .close': 'handleClose'

    initialize: ->
        @listenTo @model, 'change', @render

    handleClose: ->
    	@trigger( 'close' )