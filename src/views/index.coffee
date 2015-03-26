{ _, $, Backbone, Marionette } = require '../common.coffee'

{ TitlebarView  } = require './TitlebarView.coffee'


require( './bodyView.less' )
require( './loadingView.less' )

class BodyView extends Marionette.ItemView
	className: 'body-view'
	template: _.template """
		<div class="add-new">
			Add new magnet <input placeholder="infoHash" type="text" class="infoHash"/> <button><i class="icon-plus"></i></button>
		</div>
		<div class="magnets"></div>
	"""
	ui:
		magnets: '.magnets'
		input: '.add-new input'

	events:
		'click .add-new button': 'addMagnet'

	addMagnet: ->
		hash = @ui.input.val()
		magnet = new Backbone.Model( infoHash: hash )
		magnetView = new MagnetView( model: magnet )
		@ui.magnets.append( magnetView.render().el )

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



class module.exports.LoadingView extends Marionette.ItemView
	className: 'loading-view'
	template: _.template """
		<img src="images/logo.png" alt="Pirate Chest" />
		<p>Loading...</p>
	"""

class module.exports.AppView extends Marionette.LayoutView
	className: 'app-view'
	template: _.template """
		<div class="header"></div>
		<div class="body"></div>
		<div class="footer"></div>
	"""
	regions:
		header: '.header'
		body: '.body'
		footer: '.footer'

	initialize: ->
		require( './appView.less' )

	onShow: ->
		@header.show( new TitlebarView() )
		@body.show( new BodyView() )
