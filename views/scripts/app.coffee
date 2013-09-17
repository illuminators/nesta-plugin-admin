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

    @link.click(
      (e) ->
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
    })
    @callback_expand() if @callback_expand

  contract: ->
    @element.removeClass('expanded')
    @element.transition({
      height: '0px'
    })
    @callback_contract() if @callback_contract

class Editable
  constructor: (selector) ->
    @el = $(selector)
    @input = @el.find('input')
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
  constructor: (btn, select, template) ->
    @btn = $(btn)
    @select = $(select)
    @template = $(template)

    @bindActions()

  bindActions: ->
    base = @
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

  add: (what, where) ->
    console.log what
    template = @template.children().first().clone()
    template.find('.control-label').text(what).attr('for', what)
    template.find('input').attr({
      id: slugify(what)
      name: "meta[#{what}]"
    })

    template.insertBefore(where).removeClass('hidden')

    template.find('.remove').click (e) ->
      e.preventDefault()

      $(@).closest('.meta').remove()


$(document).ready ->
  new Editable('.header')
  new AddMoreMetadata('.add-more-metadata', '.add-more-select', '.add-more-template')
  meta = new Expander('.show-meta', '.meta')
  style = new Expander('.show-style', '.style')

  meta.addCallback(
    ->
      $('.show-meta .icon-down').transition({rotate: '-180deg'})
      style.contract()
      
    , ->
      $('.show-meta .icon-down').transition({rotate: '0deg'})
  )
  style.addCallback(
    ->
      $('.show-style .icon-down').transition({rotate: '-180deg'})
      meta.contract()
      
    , ->
      $('.show-style .icon-down').transition({rotate: '0deg'})
  )
