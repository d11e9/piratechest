{_, $, Backbone, Marionette } = require( '../common.coffee' )
{ OverlayView } = require( './index.coffee' )

class module.exports.ContentsView extends OverlayView
	template: _.template """
		<div class="overlay contents">
			<div class="content">

				<img src="images/lodestones.png" alt="">
				<p class="welcome">Inside you find a stash of <strong>Loadstones</strong> and a mysterious set of <strong>blank playing cards</strong> otherwise the box is empty save for a small <strong>note</strong>.</p>

				<code class="note">Note: This chest has been especiallly crafted to hold magnets. Long live The Pirate Bay.</code>

				<button class="button">Ok</button>
			</div>
		</div>
	"""
	events: 
		'click button': 'handleClickOpen'

	handleClickOpen: ->
		@trigger('close')