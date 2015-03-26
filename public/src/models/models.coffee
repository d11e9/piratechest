{_, $, Backbone, Marionette } = require( '../common.coffee' )
 
hashcash = window.hc = require( 'hashcashgen')
gm = require( '../lib/gossip.js')

class Magnet extends Backbone.Model
	getUri: -> "magnet:?"

class module.exports.MagnetCollection extends Backbone.Collection
	initialize: ->
		@listenTo gm, 'update', @handleGossipUpdate

	handleGossipUpdate: (peerId, key, value) =>
		if hashcash.check( key, value )
			magnet = new Magnet( infoHash: key )
			@add( magnet ) unless @contains( magnet )
		else
			console.log "Gossip hash with invalid hashcash stamp.", key, value

