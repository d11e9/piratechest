net = require 'net'

client = net.connect {port: 9001}, ->
  console.log 'connected to server!'
  client.write 'world!\r\n'

client.on 'data', (data) ->
  console.log( data.toString() )
  client.end()

client.on 'error', (err) ->
	console.error err

client.on 'end', ->
  console.log('disconnected from server')