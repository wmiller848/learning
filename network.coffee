crypto = require('crypto')
_ = require('underscore')

#################
###########
###########
##  EVENT
##  Manger for message passing (could be async in the future)
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
##  NERVE
##  Unit of input
###########
###########
#################
class Nerve
  constructor: (@input=1) ->
    @key = crypto.randomBytes(16).toString('hex')


#################
###########
###########
##  NEURON
##  Unit of compute
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
      @power += @power / 100
    else if @power > 1
      @power -= @power / 100
    @bias += (value * @power / Math.pow(@bonds, 4))

################4
###########
###########
##  WEB
##  Map of inputs and compute
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
    heavy = 100
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
    @influence+=2
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
        nerve.input = input[c]
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

        neuron = new Neuron(keys.length)
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
  evaluate: (input) ->
    keys = []
    c = 0
    nerves = []
    for nerve in @nerves
      nerve.input = input[c]
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
##  WEB
##  Manger of webs
###########
###########
#################
class Network
  constructor: (@size=2, @block_size=1) ->
    @web = new Web()
    ##
    ## size x size px image
    ##
    blocks = (@size * @size) / (@block_size * @block_size)
    console.log(blocks)
    @child_webs = []
    @child_webs.push(new Web()) for i in [0...blocks]
  get_block: (inputs, x1, y1, x2, y2) ->
    block = []
    xx = x1
    yy = y1
    working = true
    while working
      input = inputs[xx + @size * yy]
      input = -1 if typeof(input) is 'undefined'
      block.push(input)
      if xx >= x2 and yy >= y2
        working = false
        break
      xx++
      if xx > x2
        xx = x1
        yy++
        if yy > y2
          yy = y1
    block
  learn: (inputs, guideline) ->
    ##
    ## Example : 20 x 20 input
    ########
    ########    0  1  2  3  4  5  6  7  8  9  10 11 12 13 14 15 16 17 18 19 x
    ##    ##    #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #
    ##    ##    #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #
    ## 0  ## [  0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4,
    ## 1  ##    0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4,
    ## 2  ##    0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4,
    ## 3  ##    0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4,
    ## 4  ##    5, 5, 5, 5, 6, 6, 6, 6, 7, 7, 7, 7, 8, 8, 8, 8, 9, 9, 9, 9,
    ## 5  ##    5, 5, 5, 5, 6, 6, 6, 6, 7, 7, 7, 7, 8, 8, 8, 8, 9, 9, 9, 9,
    ## 6  ##    5, 5, 5, 5, 6, 6, 6, 6, 7, 7, 7, 7, 8, 8, 8, 8, 9, 9, 9, 9,
    ## 7  ##    5, 5, 5, 5, 6, 6, 6, 6, 7, 7, 7, 7, 8, 8, 8, 8, 9, 9, 9, 9,
    ## 8  ##    0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4,
    ## 9  ##    0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4,
    ## 10 ##    0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4,
    ## 11 ##    0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4,
    ## 12 ##    5, 5, 5, 5, 6, 6, 6, 6, 7, 7, 7, 7, 8, 8, 8, 8, 9, 9, 9, 9,
    ## 13 ##    5, 5, 5, 5, 6, 6, 6, 6, 7, 7, 7, 7, 8, 8, 8, 8, 9, 9, 9, 9,
    ## 14 ##    5, 5, 5, 5, 6, 6, 6, 6, 7, 7, 7, 7, 8, 8, 8, 8, 9, 9, 9, 9,
    ## 15 ##    5, 5, 5, 5, 6, 6, 6, 6, 7, 7, 7, 7, 8, 8, 8, 8, 9, 9, 9, 9,
    ## 16 ##    0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4,
    ## 17 ##    0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4,
    ## 18 ##    0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4,
    ## 19 ##    0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4  ]
    ## y  ##
    # for input_image in inputs
    #   for n in [n...5]
    #     input = input_image.splice(n, n)

    _web_guide = []
    if inputs.length > @size * @size
      return console.log("Invalid input size of #{inputs.length}")
    len = @size * @size
    x = 0
    y = 0
    for child in @child_webs
      x1 = x
      y1 = y

      x2 = x1 + (@block_size - 1)
      y2 = y1 + (@block_size - 1)

      x2 = @size - 1 if x2 >= @size
      y2 = @size - 1 if y2 >= @size

      _blocks = @get_block(inputs, x1, y1, x2, y2)
      # console.log(x1, y1, x2, y2, _blocks)
      blocks = [{
        input: _blocks,
        guideline: guideline # this is lame
      }]
      child.learn(blocks)
      x += @block_size
      if x >= @size
        x = 0
        y += @block_size
      if y >= @size
        y = 0

      evl = child.evaluate(_blocks)
      _web_guide.push(evl.sureness)
    # console.log(_web_guide, @web)
    @web.learn([{
      input: _web_guide,
      guideline: guideline
    }])
    # console.log(@web, @child_webs)
    # console.log(_web_guide)
  evaluate: (inputs) ->
    _web_guide = []
    if inputs.length > @size * @size
      return console.log("Invalid input size of #{inputs.length}")
    len = @size * @size
    x = 0
    y = 0
    for child in @child_webs
      x1 = x
      y1 = y

      x2 = x1 + (@block_size - 1)
      y2 = y1 + (@block_size - 1)

      x2 = @size - 1 if x2 >= @size
      y2 = @size - 1 if y2 >= @size

      _blocks = @get_block(inputs, x1, y1, x2, y2)
      x += @block_size
      if x >= @size
        x = 0
        y += @block_size
      if y >= @size
        y = 0

      evl = child.evaluate(_blocks)
      _web_guide.push(evl.sureness)
    # console.log(_web_guide, @web)
    @web.evaluate(_web_guide)


#################
###########
###########
##  HIVE
##
###########
###########
#################
class Hive
  constructor: (depth) ->
    @key = crypto.randomBytes(16).toString('hex')


#################
###########
###########
##
##
###########
###########
#################
exports.Web = Web
exports.Network = Network
exports.Hive = Hive
