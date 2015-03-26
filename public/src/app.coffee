fs = require('fs')

{_, $, Backbone, Marionette } = require( './common.coffee' )
{ AppView, LoadingView } = require( './views/index.coffee' )
{ nw, win } = window.nwin




# Auto reload on filesystem changes
fs.watch './', ->
	console.log "Filesystem change detected, reloading."
	window.location.reload() if window.location


appRegion = new Marionette.Region( el: $('body').get(0) )
appRegion.show( new LoadingView() )
setTimeout ( -> appRegion.show( new AppView() ) ), 1000
win.show()


