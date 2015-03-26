
{ _, $, Backbone, Marionette } = window.app = require './common.coffee'
{ AppView, LoadingView } = require './views/index.coffee'

require( './views/global.less' )

$ ->
	appRegion = new Marionette.Region( el: $('body').get(0) )
	appRegion.show( new LoadingView() )
	setTimeout ( -> appRegion.show( new AppView() ) ), 3000
	win.get().show()


