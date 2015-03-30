Datastore = require 'nedb'
path = require 'path'

db = {}
dataPath = './'

console.log "Database path: #{ dataPath } "

db.magnets = new Datastore
	filename: path.join( dataPath, 'data/magnets.db' )
	autoload: true

db.customSync = (method, model, options) ->
	console.log arguments
	switch method
		when 'create'
			db.magnets.insert model.toJSON(), (err, magnet) ->
				if err
					console.error "Unable to write to db."
					console.error err
					options.error( err, magnet )
				else 
					console.log "Magnet written to db."
					options.success( null, magnet )
		when 'read' then console.log 'TODO'
		when 'update' then console.log 'TODO'
		when 'delete' then console.log 'TODO'


module.exports.Database = db