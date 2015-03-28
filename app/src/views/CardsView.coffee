{_, $, Backbone, Marionette } = require( '../common.coffee' )


class module.exports.CardsView extends Marionette.LayoutView
	className: 'cards-view'
	template: _.template """
		<div class="content">
			<img src="images/cards.png" alt="">
			<p>The chest contains a mysterious set of blank <strong>Playing Cards</strong>.</p>
		</div>
	"""