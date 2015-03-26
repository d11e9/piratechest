{ _, Marionette } = require '../common.coffee'

require( './titlebarView.less' )

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
        window.win.get().minimize()

    handleFullscreen: ->
        console.log 'Fullscreen App'
        window.win.get().toggleFullscreen()

    handleClose: ->
        console.log 'Close App'
        window.close()

    handleDebug: ->
        console.log 'Debug App'
        window.win.get().showDevTools()
