crypto = require('crypto')
_ = require('underscore')

#################
###########
###########
##
##
###########
###########
#################
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

#################
###########
###########
##
##
###########
###########
#################
class Nerve
  constructor: ->
    @key = crypto.randomBytes(16).toString('hex')

#################
###########
###########
##
##
###########
###########
#################
class Neuron
  constructor: (@bonds=1) ->
    @bonds = 1 if @bonds <= 0
    @bias = 0
    @power = 1
  fire: (callback) ->
    callback(@bias)
  update: (value) ->
    if value > 0
      @power += 0.05
    else if @power > 1
      @power -= 0.1
    @bias += (value * @power / Math.pow(@bonds, 2))

#################
###########
###########
##
##
###########
###########
#################

class Web
  constructor: () ->
    @nerves = []
    @neurons = []
    @event = new Event()
    @positive_influence = 1
    @negative_influence = 1
    @influence = 1
  ripple: (nerves, desire, keys_str) ->
    ##
    light = 10
    heavy = 5000
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
  learn: (inputs) ->
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
    ## Go through each input and apply the learning
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


#################
###########
###########
##
##
###########
###########
#################
class Network
  constructor: (@depth=1, @topic, @description) ->
    @root_web = new Web()
    ##
    ## 20 x 20 px image
    ## 5 x 5 grid
    ## 25 - 4 x 4 webs
    ##
    @child_webs = []
    @child_webs.push(new Web()) for i in [0...25]
  learn: (inputs) ->
    ##
    ## Example : 20 x 20 image
    ## [  0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4,
    ##    0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4,
    ##    0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4,
    ##    0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4,
    ##    5, 5, 5, 5, 6, 6, 6, 6, 7, 7, 7, 7, 8, 8, 8, 8, 9, 9, 9, 9,
    ##    5, 5, 5, 5, 6, 6, 6, 6, 7, 7, 7, 7, 8, 8, 8, 8, 9, 9, 9, 9,
    ##    5, 5, 5, 5, 6, 6, 6, 6, 7, 7, 7, 7, 8, 8, 8, 8, 9, 9, 9, 9,
    ##    5, 5, 5, 5, 6, 6, 6, 6, 7, 7, 7, 7, 8, 8, 8, 8, 9, 9, 9, 9,
    ##    0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4,
    ##    0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4,
    ##    0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4,
    ##    0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4,
    ##    5, 5, 5, 5, 6, 6, 6, 6, 7, 7, 7, 7, 8, 8, 8, 8, 9, 9, 9, 9,
    ##    5, 5, 5, 5, 6, 6, 6, 6, 7, 7, 7, 7, 8, 8, 8, 8, 9, 9, 9, 9,
    ##    5, 5, 5, 5, 6, 6, 6, 6, 7, 7, 7, 7, 8, 8, 8, 8, 9, 9, 9, 9,
    ##    5, 5, 5, 5, 6, 6, 6, 6, 7, 7, 7, 7, 8, 8, 8, 8, 9, 9, 9, 9,
    ##    0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4,
    ##    0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4,
    ##    0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4,
    ##    0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4  ]
    ##
    # for input_image in inputs
    #   for n in [n...5]
    #     input = input_image.splice(n, n)

  evaluate: ->

exports.Web = Web
exports.Network = Network
