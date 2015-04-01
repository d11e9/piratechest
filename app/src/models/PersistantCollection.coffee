Datastore = require 'nedb'
path = require 'path'
_ = require 'underscore'


_handleComplete = (options) ->
	(err, resp) ->
		console.log "Got response from db: ", arguments
		if err
			options.error( err, resp )
		else
			options.success( resp )

_handleCreate = (model, options) =>
	console.log "_handleCreate:", arguments
	@store[name].insert( model.toJSON(), _handleComplete( options ) )

_handleUpdate = (name, model, options) =>
	console.log "_handleUpdate:", arguments
	@store[name].update( { id: model.get('id') }, model.toJSON(), _handleComplete( options ) )

_handleRead = (name, model, options) =>
	console.log "_handleRead:", arguments
	@store[name].find( { id: model.get('id') }, model.toJSON(), _handleComplete( options ) )

_handleDelete = (name, model, options) =>
	console.log "_handleDelete:", arguments
	@store[name].remove( { id: model.get('id') }, model.toJSON(), _handleComplete( options ) )

module.exports = ( collection, name ) ->
	collection.sync = () ->
		console.log "Syncing model to database: ", arguments
		'create': -> _handleCreate( name, model, options )
		'update': -> _handleUpdate( name, model, options )
		'read': -> _handleRead( name, model, options )
		'delete': -> _handleDelete( name, model, options )
	collection