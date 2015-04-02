Datastore = require 'nedb'
path = require 'path'
_ = require 'underscore'


class Store
	constructor: (name) ->
		@_store = new Datastore( filename: "./data/#{ name }.db", autoload: true )
	
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
		@_store.insert model.toJSON(), (err,data) -> 
			if err
				console.error( err )
				options.error( err )
			else
				options.success( data )


	_handleUpdate: (model, options) =>
		console.log "_handleUpdate:", arguments
		@_store.update { id: model.get('id') }, model.toJSON(), (err,data) -> 
			if err
				console.error( err )
				options.error( err )
			else
				options.success( data )


	_handleRead: (model, options) =>
		console.log "_handleRead:", arguments
		@_store.find { id: model.get('id') }, model.toJSON(), (err,data) -> 
			if err
				console.error( err )
				options.error( err )
			else
				options.success( data )


	_handleDelete: (model, options) =>
		console.log "_handleDelete:", arguments
		@_store.remove { id: model.get('id') }, model.toJSON(), (err,data) -> 
			if err
				console.error( err )
				options.error( err )
			else
				options.success( data )





module.exports = Store

	