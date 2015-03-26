var Gossipmonger = require('gossipmonger');


rand = function(min,max) {
    return Math.floor(Math.random() * (max - min + 1)) + min;
}

PORT = rand( 9000, 10000)
console.log( 'chatting on port ', PORT );

SEED = 9001
seeds = SEED ? [{id: "seed1", transport: { host: 'localhost', port: SEED }}] : [];
 
var gossipmonger = new Gossipmonger(
    { // peerInfo 
        id: "localId" + PORT ,
        transport: { // default gossipmonger-tcp-transport data 
            host: "localhost",
            port: PORT
        }
    },
    {   // options 
        seeds: seeds
    });
 
gossipmonger.on('error', function (error) {
    // 
});
 
gossipmonger.on('new peer', function (newPeer) {
    console.log("found new peer " + newPeer.id + " at " + newPeer.transport.host + ':' + newPeer.transport.port );
});
 
gossipmonger.on('peer dead', function (deadPeer) {
    console.log("peer " + deadPeer.id + " is now assumed unreachable");
});
 
gossipmonger.on('peer live', function (livePeer) {
    console.log("peer " + livePeer.id + " is live again");
});
 
gossipmonger.on('update', function (peerId, key, value) {
    console.log("peer " + peerId + " updated key " + key + " with " + value);  
    console.log( gossipmonger.localPeer.data )
});
 
/* **IMPORTANT**
 * Typically, one would create a `transport`, start it (call listen())
 * and then pass it in as `options.transport` in Gossipmonger constructor. This
 * makes the implementation of Gossipmonger less complex and simpler.
 * For development purposes, Gossipmonger comes with a default transport, so
 * it's easier to get a feel for it, but because of that, if you don't provide
 * a `transport`, the default one will be used but **you need to start it**.
 * The call illustrated below will start the default transport. If this isn't done,
 * you will not receive communications from other gossipmongers. */
gossipmonger.transport.listen(function () {
    console.log('default transport is listening');
});
 
gossipmonger.gossip(); // start gossiping 

module.exports = gossipmonger;