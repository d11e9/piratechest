Datastore = require 'nedb'
path = require 'path'
_ = require 'underscore'


class Store
	constructor: (name) ->
		@_store = new Datastore( filename: "./data/#{ name }.db", autoload: true )
		@_store.ensureIndex
			fieldName: 'infoHash'
			unique: true
	
	sync: (method, model, options) =>
		console.log "Syncing model to database: ", arguments
		switch method
			when 'create' then @_handleCreate( model, options )
			when 'update' then @_handleUpdate( model, options )
			when 'read' then @_handleRead( model, options )
			when 'delete' then @_handleDelete( model, options )
			else throw new Error( "Unkown method (#{ method }) for model sync.", model, options )

	_handleComplete: (options) ->
		(err, resp) ->
			console.log "Got response from db: ", arguments, this
			if err
				console.error( err )
				options.error( err, resp )
			else
				options.success( resp )

	_handleCreate: (model, options) =>
		console.log "_handleCreate:", model.toJSON()
		@_store.update {infoHash: model.get('infoHash')},  model.toJSON(), {upsert: true}, @_handleComplete( options )


	_handleUpdate: (model, options) =>
		console.log "_handleUpdate:", arguments
		@_store.update { infoHash: model.get('infoHash') }, model.toJSON(), @_handleComplete( options )


	_handleRead: (model, options) =>
		console.log "_handleRead:", arguments
		@_store.find {}, @_handleComplete( options )


	_handleDelete: (model, options) =>
		console.log "_handleDelete:", arguments
		@_store.remove { infoHash: model.get('infoHash') }, @_handleComplete( options )





module.exports = Store

	