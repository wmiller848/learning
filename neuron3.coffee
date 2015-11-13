crypto = require('crypto')
_ = require('underscore')

class Event
  constructor: ->
    @_events = {}
  trigger: (event, callback) ->
    e.fire(callback) for e in @_events[event] if @_events[event]
  ripple: (event, value) ->
    e.update(value) for e in @_events[event] if @_events[event]
  register: (event, responder) ->
    @_events[event] = [] if typeof(@_events[event]) is 'undefined'
    @_events[event].push(responder)
  is_registered: (event) ->
    typeof(@_events[event]) isnt 'undefined' ? true : false

class Nerve
  constructor: ->
    @key = crypto.randomBytes(16).toString('hex')

class Neuron
  constructor: ->
    @bias = 0
  fire: (callback) ->
    callback(@bias)
  update: (value) ->
    @bias += value

class Web
  constructor: (@topic, @description) ->
    @nerves = []
    @neurons = []
    @event = new Event()
  learn: (inputs, guidelines) ->
    ##############
    ## Make sure we have enough nerves ready for this input
    ##############
    for input in inputs
      if input.length > @nerves.length
        for i in [0...(input.length - @nerves.length)]
          @nerves.push(new Nerve())
    #############################
    ## Enforce the two guaratees
    ## 1) Each nerve has a devoted neuron
    ## 2) This unqiue set of inputs has a devoted neuron
    #############################
    for nerve in @nerves
      unless @event.is_registered(nerve.key)
        neuron = new Neuron()
        @event.register(nerve.key, neuron)
        @neurons.push(neuron)
    ##
    ##
    for input in inputs
      keys = []
      c = 0
      for nerve in @nerves
        keys.push(nerve.key) if c < input.length and input[c] isnt 0
        c++
      keys = keys.sort().join('')
      unless @event.is_registered(keys)
        neuron = new Neuron()
        @event.register(keys, neuron)
        @neurons.push(neuron)

      cost = 0
      desire = false
      ##
      for guideline in guidelines
        if _.isEqual(input, guideline)
          desire = true
      ##
      @event.trigger(nerve.key, (bias) ->
        cost += bias
      ) for nerve in @nerves
      ##
      @event.trigger(keys, (bias) ->
        cost += bias
      )
      ##
      if desire is true
        console.log('TRAINING GOOD')
        @event.ripple(nerve.key, 2) for nerve in @nerves
        @event.ripple(keys, 0.5)
      else if desire is false
        console.log('TRAINING BAD')
        @event.ripple(nerve.key, -1) for nerve in @nerves
        @event.ripple(keys, -0.5)
      console.log(cost, desire)

  evaluate: (input) ->
    keys = []
    c = 0
    for nerve in @nerves
      keys.push(nerve.key) if c < input.length and input[c] isnt 0
      c++
    keys = keys.sort().join('')
    cost = 0
    @event.trigger(nerve.key, (bias) ->
      cost += bias
    ) for nerve in @nerves
    ##
    @event.trigger(keys, (bias) ->
      cost += bias
    )
    console.log(cost)
exports.Web = Web
