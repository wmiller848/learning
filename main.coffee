network = require('./network')
_ = require('underscore')

input_size = 4*4
web = new network.Web('Basic edge recognition', 'Some cool fucking description')

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
      1,1,0,0,
      1,1,0,0,
      0,0,0,0
    ],
    guideline: true
  },
  {
    input:[
      0,0,0,0,
      0,0,1,1,
      0,0,1,1,
      0,0,0,0
    ],
    guideline: true
  },
  {
    input:[
      0,1,1,0,
      0,1,1,0,
      0,0,0,0,
      0,0,0,0
    ],
    guideline: true
  },
  {
    input:[
      0,0,0,0,
      0,0,0,0,
      0,1,1,0,
      0,1,1,0
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
  console.log('WRONG!') if thought.belief is false

  input = [
    0,0,1,1,
    0,0,1,1,
    0,0,0,0,
    0,0,0,0
  ]
  thought = web.evaluate(input)
  console.log('Good Input', input, thought)
  console.log('WRONG!') if thought.belief is false

  input = [
    0,0,0,0,
    0,1,1,0,
    0,1,1,0,
    0,0,0,0
  ]
  thought = web.evaluate(input)
  console.log('Good Input', input, thought)
  console.log('WRONG!') if thought.belief is false

  input = [
    1,1,0,0,
    1,1,0,0,
    0,0,0,0,
    0,0,0,0
  ]
  thought = web.evaluate(input)
  console.log('Good Input', input, thought)
  console.log('WRONG!') if thought.belief is false

  input = [
    0,0,0,0,
    0,0,0,0,
    0,0,1,1,
    0,0,1,1
  ]
  thought = web.evaluate(input)
  console.log('Good Input', input, thought)
  console.log('WRONG!') if thought.belief is false

  input = [
    0,0,0,0,
    0,0,1,1,
    0,0,1,1,
    0,0,0,0
  ]
  thought = web.evaluate(input)
  console.log('Good Input', input, thought)
  console.log('WRONG!') if thought.belief is false

  input = [
    1,1,0,0,
    1,1,0,0,
    0,0,1,0,
    0,0,0,0
  ]
  thought = web.evaluate(input)
  console.log('Bad Input ', input, thought)
  console.log('WRONG!') if thought.belief is true

  input = gen_random_input(input_size)
  thought = web.evaluate(input)
  console.log('Bad Input ', input, thought)
  console.log('WRONG!') if thought.belief is true

  input = gen_random_input(input_size)
  thought = web.evaluate(input)
  console.log('Bad Input ', input, thought)
  console.log('WRONG!') if thought.belief is true

  input = gen_random_input(input_size)
  thought = web.evaluate(input)
  console.log('Bad Input ', input,thought)
  console.log('WRONG!') if thought.belief is true

for i in [0...10]
  inputs = []
  inputs.push({
    input: gen_random_input(input_size),
    guideline: false
  }) for i in [0...guidelines.length * 2]

  inputs.push(guideline) for guideline in guidelines
  # console.log(inputs)
  web.learn(inputs)

evaluate_web()
# console.log(web)
