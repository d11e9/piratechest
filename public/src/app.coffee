fs = require('fs')

{_, $, Backbone, Marionette } = require( './common.coffee' )
{ AppView, LoadingView } = require( './views/index.coffee' )
{ MagnetCollection } = require( './models/models.coffee' )
{ nw, win } = window.nwin

# Auto reload on filesystem changes TODO: fix this
fs.watch './', ->
	console.log "Filesystem change detected, reloading."
	window.location.reload() if window.location


magnetCollection = new MagnetCollection()

$ ->
	appRegion = new Marionette.Region( el: $('body').get(0) )
	appRegion.show( new LoadingView() )
	# TODO: Actually load stuff not just setTimeout
	setTimeout ( -> appRegion.show( new AppView( collection: magnetCollection ) ) ), 1000
	win.show()
	setTimeout ( -> magnetCollection.add( infoHash: 'sdfsdfsdfsdfsdfsdf' ) ), 10000


