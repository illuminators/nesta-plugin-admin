class window.Menu
  constructor: (selector) ->
    @el = $(selector)
    @bindActions()

  bindActions: ->
    base = @
    @el.find('.directory li a').click( (e) ->
      e.preventDefault()
      href = $(@).attr('href')
      href = href.substr('/admin/'.length)
      dir_href = $(@).closest('.directory').data('path')
      if dir_href + 'index' != href and dir_href + href != '/index' and (href.match(/\/index$/) or href == 'index') # directory
        href = href.substr(0, href.length - "index".length)
        base.gotoDirectory(href)
      else # page
        base.gotoPage(href)
    )

  gotoPage: (path) ->
    @el.find('.directory li').removeClass('current')
    @el.find(".directory [href='/admin/#{path}']").parent().addClass('current')
    window.app.page.goto(path)

  gotoDirectory: (path) ->
    path = '/' if path == ''
    wrapper = @el.find('.inner-wrapper')

    curr_dir = $('.directory-wrapper:not(.hidden)')
    dir = $("[data-path='#{path}']").parent().removeClass('hidden')
    position = dir.position().left
    if position < curr_dir.position().left
      wrapper.css('margin-left', '-250px')
    base = @
    wrapper.transition({
        marginLeft: -position
      }, 500, ->
        base.el.find('.directory-wrapper').addClass('hidden')
        dir.removeClass('hidden')
        $(@).css('margin-left', '0')
    )
