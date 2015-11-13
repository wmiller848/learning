# neuron = require('./neuron')
neuron3 = require('./neuron3')

# size = 3 * 3
# labels = {}
# for label in [0...size]
#   labels[label] = 'Q'
#
# input =
#   size: size,
#   labels: labels

web = new neuron3.Web('Image recog', 'Some cool shit')
input = [
  [
    1,0,0,
    1,0,0,
    1,0,0
  ],
  [
    1,0,1,
    1,1,0,
    1,1,0
  ],
  [
    1,0,1,
    0,0,0,
    0,0,0
  ],
  [
    0,0,1,
    0,0,1,
    1,0,0
  ],
  [
    1,0,1,
    0,0,0,
    1,1,1
  ],
  [
    0,1,0,
    0,1,0,
    0,1,0
  ],
  [
    0,0,0,
    1,1,1,
    0,0,0
  ],
  [
    0,0,0,
    0,0,1,
    0,0,1
  ],
  [
    1,1,1,
    1,1,1,
    1,1,1
  ]
]
guidelines = [
  [
    1,1,1,
    0,0,0,
    0,0,0
  ],
  [
    1,0,0,
    1,0,0,
    1,0,0
  ],
  [
    0,0,1,
    0,0,1,
    0,0,1
  ],
  [
    0,0,0,
    0,0,0,
    1,1,1
  ],
  [
    1,0,0,
    0,1,0,
    0,0,1
  ],
  [
    0,0,1,
    0,1,0,
    1,0,0
  ],
  [
    0,1,0,
    0,1,0,
    0,1,0
  ],
  [
    0,0,0,
    1,1,1,
    0,0,0
  ]
]
# web.learn(guidelines, guidelines)
web.learn(input, guidelines)
# console.log(web.network)

console.log(web)

web.evaluate([
    0,0,0,
    1,1,1,
    0,0,0
])

web.evaluate([
    0,0,1,
    0,0,1,
    0,0,1
])

web.evaluate([
    0,0,1,
    0,0,1,
    0,0,1
])

# bias =
#   size: 3
#
# output =
#   size: 2,
#   labels:
#     0: 'Has Edges',
#     1: 'Doesnt Have Edges'

# console.log(quantum, bias, output)
#
# edge_detect = new neuron.Web(input, bias, output)
# data = (Math.random() for value in [0...input.size])
# edge_detect.fire(data)
# # console.log(edge_detect)
#
# results = edge_detect.learn()
# console.log(results)

#
# rm = web.get_random_member(0)
# console.log(rm)
