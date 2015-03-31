Datastore = require 'nedb'
path = require 'path'
_ = require 'underscore'

class module.exports.Database
	contructor: ({@dataPath, collections}) ->
		# collections  should be passed in with the format:
		# 'name': Model Constructor
		@store = {}
		@models = {}
		@addCollection( name, modelConstructor ) for own name, modelConstructor of collections
		console.log "Created Database", this
			
	addCollection: (name, modelConstructor) ->
		throw new Error("Collection [#{ name }] already exists in database.") if @store[name]?
		console.log "Adding collection [#{name}] to Database"
		@models[modelConstructor] = name
		@stores[name] = new Datastore
			filename: path.join( dataPath, "data/#{ name }.db" )
			autoload: true

	_modelSetup: (model, models) ->
		console.log "_modelSetup: ", model, models
		for constructor, name of models
			return [ name, constructor ] if model instanceof constructor
		throw new Error( 'Unable to get collection in Database for model' )

	customSync: (method, model, options) =>
		console.log "Syncing model to database: ", arguments, @
		[ name, contructor ] = @_modelSetup( model, @models )
		'create': @_handleCreate( [ name, contructor ], model, options )
		'update': @_handleUpdate( [ name, contructor ], model, options )
		'read': @_handleRead( [ name, contructor ], model, options )
		'delete': @_handleDelete( [ name, contructor ], model, options )

	_handleComplete: ([ name, contructor ], options) ->
		(err, resp) ->
			console.log "Got response from db: ", arguments
			if err
				options.error( err, resp )
			else
				options.success( resp )

	_handleCreate: ([ name, contructor ], model, options) =>
		console.log "_handleCreate:", arguments
		@store[name].insert( model.toJSON(), @_handleComplete( [ name, contructor ], options ) )

	_handleUpdate: (name, model, options) =>
		console.log "_handleUpdate:", arguments
		@store[name].update( { id: model.get('id') }, model.toJSON(), @_handleComplete( [ name, contructor ], options ) )

	_handleRead: (name, model, options) =>
		console.log "_handleRead:", arguments
		@store[name].find( { id: model.get('id') }, model.toJSON(), @_handleComplete( [ name, contructor ], options ) )

	_handleDelete: (name, model, options) =>
		console.log "_handleDelete:", arguments
		@store[name].remove( { id: model.get('id') }, model.toJSON(), @_handleComplete( [ name, contructor ], options ) )
