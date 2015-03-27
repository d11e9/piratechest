{_, $, Backbone, Marionette } = require( '../common.coffee' )


class module.exports.SettingsView extends Marionette.LayoutView
	className: 'settings-view'
	template: _.template """
		<div class="content">
			<h1>Settings</h1>
			<form action="">
				
			</form>
		</div>
	"""