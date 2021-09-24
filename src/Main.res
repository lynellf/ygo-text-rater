  type brain = {fromJSON: (. {.}) => unit}

   @module("brain.js") @new external neuralNetworkGPU: () => brain = "NeuralNetworkGPU"

  @module("brain.js")
  external likely: (~input: array<int>, brain) => string = "likely"

  @module external model: 'a = "ygo-text-model"

let rateText = (sentence) => {
  let net = neuralNetworkGPU()

  net.fromJSON(. model)

  let splitByPunctuation = str =>
    Js.String.splitByRe(%re("/[.!?,;:]/g"), str)->Belt.Array.keepMap(str => str)

  let encodePhrases = phrases => Belt.Array.map(phrases, phrase => Encoder.encode(phrase))

  let ratePhrase = input => likely(~input, net)

  let rateSentence = phrases => Belt.Array.map(phrases, ratePhrase)

  sentence->splitByPunctuation->encodePhrases->rateSentence
}
