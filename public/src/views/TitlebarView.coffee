
{ _, $, Backbone, Marionette } = require( '../common.coffee' )
{ nw, win } = window.nwin

class module.exports.TitlebarView extends Marionette.ItemView
    className: 'titlebar-view'
    template: _.template """
        <div class="controls">
            <div class="close">
                <i class="icon-remove"></i>
            </div>
            <div class="min">
                <i class="icon-minus"></i>
            </div>
            <div class="max">
                <i class="icon-plus"></i>
            </div>
        </div>
        <div class="debug">
            <i class="icon-cogs"></i>
        </div>
        <div class="title">Pirate Chest</div>
    """
    events:
        'click .close': 'handleClose'
        'click .max': 'handleFullscreen'
        'click .min': 'handleMinify'
        'click .debug': 'handleDebug'

    handleMinify: ->
        console.log 'Minify App'
        win.minimize()

    handleFullscreen: ->
        console.log 'Fullscreen App'
        win.toggleFullscreen()

    handleClose: ->
        console.log 'Close App'
        win.close()

    handleDebug: ->
        console.log 'Debug App'
        win.showDevTools()