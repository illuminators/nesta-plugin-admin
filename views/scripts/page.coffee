slugify = (value) ->
  value.toLowerCase().replace(/-+/g, '').replace(/\s+/g, '-').replace(/[^a-z0-9-]/g, '');

class Expander
  constructor: (link, element, callback_expand, callback_contract) ->
    @link = $(link)
    @element = $(element)
    @callback_expand = callback_expand
    @callback_contract = callback_contract

    @prepare()
    @bindActions()

  addCallback: (expand, contract) ->
    @callback_expand = expand if expand
    @callback_contract = contract if contract

  prepare: ->
    @element
      .removeClass('hidden')
    @orig_height = @element.css('height')
    @element
      .css({
        height: 0
        overflow: 'hidden'
      })
  bindActions: ->
    base = @

    @link.click( (e) ->
      e.preventDefault()
      if base.element.hasClass('expanded')
        base.contract()
      else
        base.expand()
    )

  expand: ->
    @element.addClass('expanded')
    @element.transition({
      height: @orig_height
    }, 500, ->
      $(@).height('auto')
    )
    @callback_expand() if @callback_expand

  contract: ->
    if @element.hasClass('expanded')
      @orig_height = @element.height()
      @element.removeClass('expanded').css('height', @orig_height)
      @element.transition({
        height: '0px'
      }, 500)
      @callback_contract() if @callback_contract

class Editable
  constructor: (selector) ->
    @el = $(selector)
    @input = @el.find('.input')
    @btn = @el.find('.edit')
    @text = @el.find('.text')

    @bindActions()

  bindActions: ->
    base = @
    @btn.click (e) ->
      e.preventDefault()

      base.showInput()

  showInput: ->
    @btn.addClass('hidden')
    @text.addClass('hidden')
    base = @
    @input
      .removeClass('hidden')
      .focus()
      .on('blur', (e) ->
        base.hideInput()
      )

  hideInput: ->
    @btn.removeClass('hidden')
    @text.removeClass('hidden')
    @input.addClass('hidden')

class AddMoreMetadata
  constructor: (meta, btn, select, template) ->
    @el = $(meta)
    @btn = $(btn)
    @select = $(select)
    @template = $(template)
    @tmp_opts = {}

    @bindActions()

  bindActions: ->
    base = @

    #adding new meta
    @btn.click (e) ->
      e.preventDefault()

      $select_clone = base.select.clone()
        .insertBefore(@).removeClass('hidden')

      $(@).addClass('hidden')
      $btn = $(@)
      $select_clone.find('.remove').click (e) ->
        e.preventDefault()

        $btn.removeClass('hidden')
        $select_clone.remove()

      $select_clone.find('.add').click (e) ->
        e.preventDefault()

        base.add($select_clone.find('select').val(), $select_clone)
        $select_clone.remove()
        $btn.removeClass('hidden')

    # removable meta
    @el.on 'click', '.control-group .remove', (e) ->
      e.preventDefault()
      what = $(@).closest('.control-group').find('input').attr('name')
      what = what.substr('meta['.length, what.length - 1 - 'meta['.length)
      $(@).closest('.control-group').remove()
      $opt = $("<option value='#{what}'>#{base.tmp_opts[what]}</option>")
      base.select.find('select').prepend $opt
      base.el.find('.add-more-select:not(.hidden)').remove()
      base.btn.removeClass('hidden')

  add: (what, where) ->
    $opt = @select.find("option[value='#{what}']")
    @tmp_opts[what] = $opt.text()
    $opt.remove()

    template = @template.children().first().clone()
    template.find('.control-label').text(@tmp_opts[what]).attr('for', what)
    template.find('input').attr({
      id: slugify(what)
      name: "meta[#{what}]"
    })

    template.insertBefore(where.closest('.options')).removeClass('hidden')

class Preview
  constructor: (selector, path) ->
    @el = $(selector)
    @iframe = @el.find('iframe')
    @show(path)

  showLoader: ->
    @el.find('.loader').removeClass('hidden')

  hideLoader: ->
    @el.find('.loader').addClass('hidden')
    
  show: (path) ->
    @iframe.attr('src', path)
    
    base = @
    @showLoader()
    @iframe.load ->
      zoom_level = base.el.width() / $('body').width()
      $('body', frames['preview'].document).css('zoom', zoom_level)
      base.hideLoader()

  render: (markup) ->
    text = $('article[role="main"]', frames['preview'].document)
    text.html(marked(markup))

class window.Page
  constructor: (selector, path) ->
    @path = path
    @el = $(selector)
    @header = new Editable(@el.find('.header'))
    new AddMoreMetadata('.head .meta', '.add-more-metadata', '.add-more-select', '.add-more-template')
    @meta = new Expander('.show-meta', '.meta')
    @style = new Expander('.show-style', '.style')
    @preview = new Preview('#preview', path)

    @addCallbacks()

  addCallbacks: ->
    base = @
    @meta.addCallback(
      ->
        $('.show-meta .icon-down').transition({rotate: '-180deg'})
        base.style.contract()
        
      , ->
        $('.show-meta .icon-down').transition({rotate: '0deg'})
    )
    @style.addCallback(
      ->
        $('.show-style .icon-down').transition({rotate: '-180deg'})
        base.meta.contract()
        
      , ->
        $('.show-style .icon-down').transition({rotate: '0deg'})
    )
    @el.on('keyup', '[name="body"], [name="heading"]', (e) ->
      heading = base.el.find('[name="heading"]').val()
      markup = base.el.find('[name="body"]').val()
      markup = '#' + heading + '\n\n' + markup unless heading.length == 0
      base.preview.render(markup)
    )

  showLoader: ->
    loader = @el.find('.loader')
    orig_opacity = loader.css('opacity')
    loader
      .removeClass('hidden')
      .css('opacity', 0)
      .transition({opacity: orig_opacity}, 300)

  showLoader: ->
    @el.find('.loader').removeClass('hidden')

  hideLoader: ->
    @el.find('.loader').addClass('hidden')

  goto: (path) ->
    base = @
    @showLoader()
    $.getJSON("/admin/#{path}", (d) ->
      base.show(d)
      base.hideLoader()
      path = '/' + path unless path[0] == '/'
      base.preview.show(path)
    )

  show_heading: (heading) ->
    $heading = @el.find('.head .header')
    if heading and heading.length >= 0
      $heading.find('.text')
        .removeClass('hidden')
        .find('h1')
          .text(heading)
      $heading.find('.input')
        .addClass('hidden')
        .find('input#heading')
          .val(heading)
    else
      $heading.find('.text')
        .addClass('hidden')
        .find('h1')
          .text('')
      $heading.find('.input')
        .removeClass('hidden')
        .find('input#heading')
          .val('')

  show_metadata: (meta) ->
    $meta = @el.find('.head .meta')
    $template = $meta.find('.add-more-template .control-group')
    $select = $meta.find('.add-more-select select')
    for m of meta
      val = unless meta[m] == null then meta[m] else ''

      $m = $meta.find("input#meta_#{m}")
      unless $m.length == 0
        $m.val(val)
      else
        $t = $template.clone()
        $t.find('label')
          .text(m)
          .attr('for', "meta_#{m}")
        $t.find('input')
          .attr(
            id: "meta_#{m}"
            name: "meta[#{m}]")
          .val(val)
        $meta.find('.options')
          .before($t)

  show_style: (style) ->
    $style = @el.find('.head .style')
    $style.find('select#meta_template')
      .val(style.template)
    $style.find('select#meta_layout')
      .val(style.layout)

  show_body: (markup) ->
    $body = @el.find('.body textarea[name="body"]')
    $body.val(markup)

  show: (data) ->
    @show_heading(data.heading)
    @show_metadata(data.meta)
    @show_style(data.style)
    @show_body(data.body_markup)
