global.document = window.document

_ = require 'underscore'
$ = require 'jquery'
Backbone = require 'backbone'
Backbone.$ = $
Marionette = require 'backbone.marionette'

module.exports = { _, $, Backbone, Marionette }
