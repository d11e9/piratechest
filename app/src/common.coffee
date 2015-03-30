
global.document = window.document
localStorage = window.localStorage

{ nw, win } = window.nwin
{ Database } = require './Database.coffee'

_ = require 'underscore'
$ = require 'jquery'
Backbone = require 'backbone'
Backbone.$ = $
Backbone.sync = Database.customSync
Marionette = require 'backbone.marionette'


module.exports = { _, $, Backbone, Marionette, nw, win, localStorage }
