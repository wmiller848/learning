#####
#
# Gradient accent aproach
#
#####

# exports = {} if typeof exports is 'undefined'

class Neuron
  constructor: (@threshold, @_backward_links, @_forward_links, @labels) ->
    @reset()
  set_backward_links: (@_backward_links=[]) ->
    @_backward_links_weights = new Array(@_backward_links.length)
    for i in [0...@_backward_links_weights.length]
      @_backward_links_weights[i] = @threshold
  set_forward_links: (@_forward_links=[]) ->
    @_forward_links_weights = new Array(@_forward_links.length)
    for i in [0...@_forward_links_weights.length]
      @_forward_links_weights[i] = @threshold
  reset: ->
    @_trigger_count = 0
    @set_backward_links(@_backward_links)
    @set_forward_links(@_forward_links)
  receive: () ->
    @_trigger_count++
  fire: (input=null) ->
    if input isnt null
      @status = input
    else
      @status = @result()
    if @_forward_links and @_forward_links_weights
      for i in [0...@_forward_links.length]
        @_forward_links[i]?.receive() if @status >= @_forward_links_weights[i]
  result: ->
    if @_forward_links and @_forward_links?.length isnt 0
      @_trigger_count / @_forward_links.length
    else if @_backward_links and @_backward_links?.length isnt 0
      @_trigger_count / @_backward_links.length
    else
      0.0
  adjust: (value) ->
    @threshold += value
  set: (value) ->
    @threshold = value

class Web
  constructor: (inputs, biases, outputs) ->
    @inputs = (new Neuron(0.0, null, null, inputs.labels[input]) for input in [0...inputs.size])

    # @biases = (new Neuron(Math.random(), null, null, null) for bias in [0...biases.size])
    # @outputs = (new Neuron(0.0, null, null, outputs.labels[output]) for output in [0...outputs.size])
    ##
    # console.log("Inputs", @inputs)
    # console.log("Biases", @biases)
    # console.log("Outputs", @outputs)
    ##
    input.set_forward_links(@biases) for input in @inputs
    ##
    bias.set_backward_links(@inputs) for bias in @biases
    bias.set_forward_links(@outputs) for bias in @biases
    ##
    output.set_backward_links(@biases) for output in @outputs
  fire: (data) ->
    if data.length is @inputs.length
      console.log("Firing inputs")
      @inputs[i].fire(data[i]) for i in [0...@inputs.length]
      console.log("Firing biases")
      @biases[i].fire() for i in [0...@biases.length]
    else
      console.log('Data length does not match input length')
  learn: (correct_result) ->
    console.log(@biases)
    console.log(@outputs)
    results = (output.result() for output in @outputs)
    bias.reset() for bias in @biases
    output.reset() for output in @outputs
    results

exports.Web = Web
