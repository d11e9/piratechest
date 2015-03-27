fs = require('fs')

{_, $, Backbone, Marionette } = require( './common.coffee' )
{ AppView, LoadingView } = require( './views/index.coffee' )
{ IntroView } = require './views/IntroView.coffee'
{ ContentsView } = require './views/ContentsView.coffee'
{ MagnetCollection, Magnet } = require( './models/models.coffee' )
{ nw, win } = window.nwin

WebTorrent = require 'webtorrent'
client = new WebTorrent()

# Auto reload on filesystem changes TODO: fix this
# fs.watch './', ->
# 	console.log "Filesystem change detected, reloading."
# 	window.location.reload() if window.location


magnetCollection = new MagnetCollection()

$ ->
	appRegion = new Marionette.Region( el: $('body').get(0) )
	appRegion.show( new LoadingView() )
	# TODO: Actually load stuff not just setTimeout
	appView = new AppView( collection: magnetCollection )
	setTimeout ( ->
		appRegion.show( appView )
		introView = new IntroView()
		appView.showOverlay( introView )
		introView.on 'close', ->
			appView.showOverlay( new ContentsView() )
			
	), 1000
	win.show()
	setTimeout ( -> 
		magnetCollection.add new Magnet
			infoHash: '546cf15f724d19c4319cc17b179d7e035f89c1f4'
			favorite: true
		magnetCollection.add new Magnet
			infoHash: 'b3bcb8bd8b20dec7a30fd9ec43ce7afaaf631e06'
	), 10000


