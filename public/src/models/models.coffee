{_, $, Backbone, Marionette } = require( '../common.coffee' )
 
hashcash = window.hc = require( 'hashcashgen')
gm = require( '../lib/gossip.js')

class Magnet extends Backbone.Model
	defaults: ->
		favorite: false

	getUri: -> "magnet:?"

class MagnetCollection extends Backbone.Collection
	initialize: ->
		@listenTo gm, 'update', @handleGossipUpdate
		@listenTo this, 'add', @handleCollectionAdd


	handleCollectionAdd: (model) ->
		hash = model.get('infoHash')
		gm.update( hash, hashcash( hash, 4 ) )

	handleGossipUpdate: (peerId, key, value) =>
		if hashcash.check( key, value )
			magnet = new Magnet
				infoHash: key
				favorite: false
			@add( magnet ) unless @where( infoHash: key ).length > 0
		else
			console.log "Gossip hash with invalid hashcash stamp.", key, value

module.exports = { Magnet, MagnetCollection }