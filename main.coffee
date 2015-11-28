network = require('./network')
_ = require('underscore')

gen_random_input = (num_inputs) ->
  input = []
  input.push(parseInt(Math.random()*2)) for i in [0...num_inputs]
  input

input_size = 4*4 # 20 * 20
input_square = 4 # 20
block_size = 1
network = new network.Network(input_square, block_size)

network.learn([
  1,1,0,0,
  1,1,0,0,
  0,0,0,0,
  0,0,0,0
], true)

network.learn([
  0,0,1,1,
  0,0,1,1,
  0,0,0,0,
  0,0,0,0
], true)

network.learn([
  0,0,0,0,
  0,0,0,0,
  0,0,1,1,
  0,0,1,1
], true)

network.learn([
  0,0,0,0,
  0,0,0,0,
  1,1,0,0,
  1,1,0,0
], true)

for i in [0...25]
  network.learn(gen_random_input(input_size), false)

input = [
  0,0,1,1,
  0,0,1,1,
  0,0,0,0,
  0,0,0,0
]
t = network.evaluate(input)
console.log("PRIME", input, t)

input = [
  1,1,0,1,
  1,1,0,0,
  0,0,0,0,
  0,0,0,0
]
t = network.evaluate(input)
console.log("CLOSE", input, t)

input = [
  0,0,0,0,
  1,1,0,0,
  1,1,0,0,
  0,0,0,0
]
t = network.evaluate(input)
console.log("PRIME NOT SHOWN", input, t)

input = gen_random_input(input_size)
t = network.evaluate(input)
console.log("RANDOM", input, t)
