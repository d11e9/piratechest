{_, $, Backbone, Marionette, localStorage } = require( '../common.coffee' )

Lodestone = require( '../lib/lodestone')

{ MagnetCollectionView  } = require './MagnetCollectionView.coffee'
{ Magnet, MagnetCollection } = require '../models/models.coffee'

class module.exports.LodestoneView extends Marionette.LayoutView
	className: 'lodestone-view'
	template: _.template """
		<div class="content">
			<form class="search" action="">
				<i class="icon-search"></i><input type="text" placeholder="Search">
			</form>
			<div class="searches"></div>
			<div class="output"></div>
		</div>
	"""
	events:
		'submit form': '_handleSearch'
	ui:
		input: 'input'

	noop: (ev) ->
		ev.preventDefault()
		false

	regions:
		searchesRegion: '.searches'
		output: '.output'

	initialize: ({@torrentClient, @config, collection}) ->
		console.log "INIT LodestoneView", @torrentClient
		@lodestone = window.lodestone = new Lodestone( {data: {}, seeds: @config?.customSeeds } ) if config?.flags?.connectLodestoneOnStartup
		

	onShow: ->
		@lodestone ?= window.lodestone = new Lodestone( {data: {}, seeds: @config?.customSeeds } )	
		@listenTo @lodestone, 'peer', @_handleAddPeer
		@listenTo @lodestone, 'data', @_handleData

		@searchResults = new MagnetCollection([], { @torrentClient } )
		@resultsView = new MagnetCollectionView( collection: @searchResults )
		@output.show( @resultsView )

		@searches = new Backbone.Collection()
		@searchesRegion.show( new LodestoneSearchCollectionView( collection: @searches ) )

	_handleSearch: (ev) ->
		ev.preventDefault()
		input = @ui.input.val()
		search = new Backbone.Model( input: input )
		@searches.add( search )
		@lodestone.addSearch( input )
		false

	_handleData: (data) =>
		for infoHash in data.hashes
			magnet = new Magnet( infoHash: infoHash )
			@collection.add( magnet )

	_handleAddPeer: =>
		console.log 'new peer', arguments


class LodestoneEmptyView extends Marionette.ItemView
	className: 'lodestone-empty-view'
	template: _.template """
        <img src="images/lodestones.svg" alt="">
        <p><strong>Lodestone Search</strong> is a <em>work in progress</em> private distributed search engine for magnets.</p>
	"""

class LodestoneSearchView extends Marionette.ItemView
	className: 'lodestone-search-view'
	template: _.template """
		<% for (var tag in tags) { %><span class="tag"><%- tags[tag] %></span><% } %><i class="icon-remove remove-search"></i>
	"""
	events:
		'click .remove-search': '_handleRemoveSearch'

	templateHelpers: =>
		tags: @model.get( 'input' ).split( /\W+/ )

	_handleRemoveSearch: ->
		@model.destroy()

class LodestoneSearchCollectionView extends Marionette.CollectionView
	className: 'lodestone-search-collection-view'
	childView: LodestoneSearchView
	emptyView: LodestoneEmptyView



