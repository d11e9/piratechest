
{ _, $, Backbone, Marionette } = window.app = require './common.coffee'
{ AppView } = require './views/index.coffee'


$ ->
	appRegion = new Marionette.Region( el: $('body').get(0) )
	appRegion.show( new AppView() )


