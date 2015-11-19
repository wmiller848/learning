crypto = require('crypto')
_ = require('underscore')

class Event
  constructor: ->
    @_events = {}
  trigger: (event, callback) ->
    e?.fire(callback) for e in @_events[event] if @_events[event]
  ripple: (event, value) ->
    e?.update(value) for e in @_events[event] if @_events[event]
  register: (event, responder) ->
    @_events[event] = [] if typeof(@_events[event]) is 'undefined'
    @_events[event].push(responder)
  is_registered: (event) ->
    typeof(@_events[event]) isnt 'undefined' ? true : false
  registered_count: (event) ->
    if @is_registered(event)
      @_events[event].length
    else
      0

class Nerve
  constructor: ->
    @key = crypto.randomBytes(16).toString('hex')

class Neuron
  constructor: (@bonds=1) ->
    @bonds = 1 if @bonds <= 0
    @bias = 0
    @power = 1
  fire: (callback) ->
    callback(@bias / @bonds)
  update: (value) ->
    if value > 0
      @power += 0.01
    else if @power > 1
      @power -= 0.1
    @bias += (value * @power / @bonds)


class Web
  constructor: (@topic, @description) ->
    @nerves = []
    @neurons = []
    @event = new Event()
    @positive_influence = 1
    @negative_influence = 1
    @influence = 1
  ripple: (nerves, desire, keys_str) ->
    ##
    light = 10
    heavy = 1000
    ##
    ##
    if desire is true
      # console.log('TRAINING GOOD')
      light_influence = light / (@positive_influence + @influence)
      heavy_influence = heavy / (@positive_influence + @influence)
      # console.log(light_influence, heavy_influence)
      @event.ripple(nerve.key, light_influence) for nerve in nerves
      @event.ripple(keys_str, heavy_influence)
      @positive_influence++
    else if desire is false
      # console.log('TRAINING BAD')
      light_influence = -light / (@negative_influence + @influence)
      heavy_influence = -heavy / (@negative_influence + @influence)
      # console.log(light_influence, heavy_influence)
      @event.ripple(nerve.key, light_influence) for nerve in nerves
      @event.ripple(keys_str, heavy_influence)
      @negative_influence++
    @influence++
  learn: (inputs, guidelines) ->
    ##############
    ## Make sure we have enough nerves ready for this input
    ##############
    for input_obj in inputs
      if input_obj.input.length > @nerves.length
        for i in [0...(input_obj.input.length - @nerves.length)]
          @nerves.push(new Nerve())
    #############################
    ## Enforce the three guaratees
    ## 1) Each nerve has a devoted neuron
    ## 2) This unique set of inputs has one devoted neuron
    ## 3) This unique set of inputs has at least one distributed neuron
    #############################
    for nerve in @nerves
      unless @event.is_registered(nerve.key)
        neuron = new Neuron()
        @event.register(nerve.key, neuron)
        @neurons.push(neuron)
    ##
    ## Go through each input and
    ##
    for input_obj in inputs
      input = input_obj.input
      desire = input_obj.guideline
      ##
      ##
      keys = []
      c = 0
      nerves = []
      for nerve in @nerves
        nerves.push(nerve) if c < input.length and input[c] isnt 0
        c++
      ##
      for nerve in nerves
        keys.push(nerve.key)
      keys.sort()
      if keys.length is 0
        continue
      keys_str = keys.join('')
      unless @event.is_registered(keys_str)
        neuron = new Neuron()
        @event.register(keys_str, neuron)
        @neurons.push(neuron)

        neuron = new Neuron(keys.length * 3) # magic scaling value
        # neuron = new Neuron()
        # @event.register(keys_str, null) # register a stub
        @event.register(key, neuron) for key in keys
        @neurons.push(neuron)

      sureness = 0
      ##
      @event.trigger(nerve.key, (bias) ->
        sureness += bias
      ) for nerve in nerves
      ##
      @event.trigger(keys_str, (bias) ->
        sureness += bias
      )

      @ripple(nerves, desire, keys_str)

  evaluate: (input, guideline) ->
    keys = []
    c = 0
    nerves = []
    for nerve in @nerves
      nerves.push(nerve) if c < input.length and input[c] isnt 0
      c++
    for nerve in nerves
      keys.push(nerve.key)
    keys.sort()
    keys_str = keys.join('')
    sureness = 0
    @event.trigger(nerve.key, (bias) ->
      sureness += bias
    ) for nerve in nerves
    ##
    @event.trigger(keys_str, (bias) ->
      sureness += bias
    )
    if typeof(guideline) isnt 'undefined'
      @ripple(nerves, guideline, keys_str)

    threshold = 0
    belief: (sureness > threshold ? true : false),
    sureness: sureness

exports.Web = Web
