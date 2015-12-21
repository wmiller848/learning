network = require('./network')
pngparse = require('pngparse')
_ = require('underscore')

#
# gen_random_input = (num_inputs) ->
#   input = []
#   input.push(parseInt(Math.random()*2)) for i in [0...num_inputs]
#   input

pngparse.parseFile('./training_data/numbers/0_1.png', (err, img) ->
  if(err)
    throw err
  console.log(err, img)

  if img.width != img.height
    throw new Error("Image must be sqaure")

  input_square = img.width
  input_size = input_square * input_square
  block_size = 4
  network = new network.Network(input_square, block_size)

  data = img.data

  ##
  ##
  i = 0
  x = 0
  y = 0
  while i < data.length
    if x % block_size == 0
      console.log(y)
      y++

    pixel = [data[i+0], data[i+1], data[i+2], data[i+3]]
    ii = i/img.channels
    console.log("Pixel #{ii} #{x} -", pixel)

    x++
    i += img.channels
    if ii != 0 && (ii+1) % input_square == 0
      console.log("================================================")
      x = 0
      y = 0

  inputs = []
  i = 0
  while i < data.length
    inputs.push(data[i])
    i+=4
  network.learn(inputs, true)
)


#
# input_size = 4*4 # 20 * 20
# input_square = 4 # 20
# block_size = 1
# network = new network.Network(input_square, block_size)
#
# network.learn([
#   1,1,0,0,
#   1,1,0,0,
#   0,0,0,0,
#   0,0,0,0
# ], true)
#
# network.learn([
#   0,0,1,1,
#   0,0,1,1,
#   0,0,0,0,
#   0,0,0,0
# ], true)
#
# network.learn([
#   0,0,0,0,
#   0,0,0,0,
#   0,0,1,1,
#   0,0,1,1
# ], true)
#
# network.learn([
#   0,0,0,0,
#   0,0,0,0,
#   1,1,0,0,
#   1,1,0,0
# ], true)
#
# for i in [0...25]
#   network.learn(gen_random_input(input_size), false)
#
# input = [
#   0,0,1,1,
#   0,0,1,1,
#   0,0,0,0,
#   0,0,0,0
# ]
# t = network.evaluate(input)
# console.log("PRIME", input, t)
#
# input = [
#   1,1,0,1,
#   1,1,0,0,
#   0,0,0,0,
#   0,0,0,0
# ]
# t = network.evaluate(input)
# console.log("CLOSE", input, t)
#
# input = [
#   0,0,0,0,
#   1,1,0,0,
#   1,1,0,0,
#   0,0,0,0
# ]
# t = network.evaluate(input)
# console.log("PRIME NOT SHOWN", input, t)
#
# input = gen_random_input(input_size)
# t = network.evaluate(input)
# console.log("RANDOM", input, t)
