# neuron = require('./neuron')
neuron3 = require('./neuron3')
_ = require('underscore')

input_size = 4*4
web = new neuron3.Web('Basic edge recognition', 'Some cool fucking description')
console.log(web)

guidelines = [
  {
    input:[
      1,1,0,0,
      1,1,0,0,
      0,0,0,0,
      0,0,0,0
    ],
    guideline: true
  },
  {
    input:[
      0,0,1,1,
      0,0,1,1,
      0,0,0,0,
      0,0,0,0
    ],
    guideline: true
  },
  {
    input:[
      0,0,0,0,
      0,0,0,0,
      1,1,0,0,
      1,1,0,0
    ],
    guideline: true
  },
  {
    input:[
      0,0,0,0,
      0,0,0,0,
      0,0,1,1,
      0,0,1,1
    ],
    guideline: true
  },
  {
    input:[
      0,0,0,0,
      0,1,1,0,
      0,1,1,0,
      0,0,0,0
    ],
    guideline: true
  },
  {
    input:[
      1,1,1,1,
      1,1,1,1,
      1,1,1,1,
      1,1,1,1
    ],
    guideline: true
  }
]

gen_random_input = (num_inputs) ->
  input = []
  input.push(parseInt(Math.random()*2)) for i in [0...num_inputs]
  for guideline in guidelines
    return gen_random_input(num_inputs) if _.isEqual(input, guideline.input)
  input

evaluate_web = ->
  input = [
    1,1,1,1,
    1,1,1,1,
    1,1,1,1,
    1,1,1,1
  ]
  thought = web.evaluate(input)
  console.log('Good Input', input, thought)

  input = [
    0,0,1,1,
    0,0,1,1,
    0,0,0,0,
    0,0,0,0
  ]
  thought = web.evaluate(input)
  console.log('Good Input', input, thought)

  input = [
    0,0,0,0,
    0,1,1,0,
    0,1,1,0,
    0,0,0,0
  ]
  thought = web.evaluate(input)
  console.log('Good Input', input, thought)

  input = [
    1,1,0,0,
    1,1,0,0,
    0,0,0,0,
    0,0,0,0
  ]
  thought = web.evaluate(input)
  console.log('Good Input', input, thought)

  input = [
    0,0,0,0,
    0,0,0,0,
    0,0,1,1,
    0,0,1,1
  ]
  thought = web.evaluate(input)
  console.log('Good Input', input, thought)

  input = [
    1,1,0,0,
    1,1,0,0,
    0,0,1,0,
    0,0,0,0
  ]
  thought = web.evaluate(input)
  console.log('Bad Input ', input, thought)

  input = gen_random_input(input_size)
  thought = web.evaluate(input)
  console.log('Bad Input ', input, thought)

  input = gen_random_input(input_size)
  thought = web.evaluate(input)
  console.log('Bad Input ', input, thought)

  input = gen_random_input(input_size)
  thought = web.evaluate(input)
  console.log('Bad Input ', input,thought)

for i in [0...100]
  inputs = []
  inputs.push({
    input: gen_random_input(input_size),
    guideline: false
  }) for i in [0...6]

  inputs.push(guideline) for guideline in guidelines
  # console.log(inputs)
  web.learn(inputs)

evaluate_web()
console.log(web)
