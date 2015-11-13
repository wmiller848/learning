crypto = require('crypto')
_ = require('underscore')

class Web
  constructor: (@topic, @description) ->
    @network = new Network()
  _check: (input) ->
    if input.length > @network._neuron_len
      for i in [0...(input.length - @network._neuron_len)]
        neuron = new Neuron2()
        @network.register_neuron(neuron.key, neuron)
  _happy: (query) ->
    @network.insert(query, 1)
  _angry: (query) ->
    @network.insert(query, -1)
  learn: (inputs, guidelines) ->
    for input in inputs
      @_check(input)
    ## Begin to learn
    total_cost = 0
    for input in inputs
      cost = 0
      desire = false
      for guideline in guidelines
        if _.isEqual(input, guideline)
          desire = true

      query = new Query()
      for key, neuron of @network.neurons
        neuron.bound(query) if input.pop() > 0
      cost = @network.search(query)
      total_cost += cost
      if desire is true
        @_happy(query)
      else
        # @_angry(query)
  evaluate: (input) ->
    @_check(input)
    query = new Query()
    for key, neuron of @network.neurons
      neuron.bound(query) if input.pop() > 0
    cost = @network.search(query)
    # console.log(@network.synopsis, query, cost)
    if cost > 0
      console.log('Yes!')
    else
      console.log('No!')

class Network
  constructor: (cached, cached_len) ->
    @neurons = {}
    @_neuron_len = 0
    @synopsis = {}
    @_synopsis_len = 0
    if cached and cached_len
      @synopsis = cached
      @_synopsis_len = cached_len
  register_neuron: (key, neuron) ->
    @neurons[key] = neuron
    @_neuron_len++
  register_synopsis: (key, synopsis) ->
    @synopsis[key] = synopsis
    @_synopsis_len++
  search: (query) ->
    hash = query.hash()
    result = @synopsis[hash]
    if typeof(result) is 'undefined' or result is ''
      result = query.expand()
      @register_synopsis(hash, result)
    result.activate()
  insert: (query, value) ->
    hash = query.hash()
    result = @synopsis[hash]
    if typeof(result) is 'undefined' or result is ''
      console.log('No matching Synapse')
    else
      result.value += value

class Query
  constructor: ->
    @keys = []
    @expanded = false
    @synapsis = null
  add: (key) ->
    @keys.push(key)
  hash: ->
    @keys = @keys.sort()
    hash = ''
    hash += "#{key.toString()}" for key in @keys
  expand: () ->
    unless @expanded
      @expanded = true
      new Synapse(@keys)
    else
      null

class Synapse
  constructor: (@keys) ->
    @value = 0
  activate: ->
    @value

class Neuron2
  constructor: ->
    @key = crypto.randomBytes(64).toString('hex')
  bound: (query) ->
    query.add(@key)
  # activate: ->

exports.Web = Web
