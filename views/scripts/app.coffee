class window.App
  constructor: ->
    @menu = new window.Menu('.directories-wrapper')
    path = window.location.pathname
    path = path.substr('/admin'.length, path.length)
    path = '/' if path.length == 0
    @page = new window.Page('#editor', )

$(document).ready ->
  window.app = new window.App
