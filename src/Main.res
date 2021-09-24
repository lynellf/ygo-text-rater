module Main = {
  module BrainJS = {
    type brain = {fromJSON: (~model: {.}) => unit}
    module NeuralNetworkGPU = {
      @module("brain.js") @scope("default") @new external make: brain = "NeuralNetworkGPU"
    }

    @module("brain.js") @scope("default")
    external likely: (~input: array<int>, brain) => string = "NeuralNetworkGPU"
  }

  @module external model: 'a = "ygo-text-model"

  let net = BrainJS.NeuralNetworkGPU.make

  net.fromJSON(~model)

  let splitByPunctuation = str =>
    Js.String.splitByRe(%re("/[.!?,;:]/g"), str)->Belt.Array.keepMap(str => str)

  let encodePhrases = phrases => Belt.Array.map(phrases, phrase => Encoder.encode(phrase))

  let ratePhrase = input => BrainJS.likely(~input, net)

  let rateSentence = phrases => Belt.Array.map(phrases, ratePhrase)

  let default = sentence => sentence->splitByPunctuation->encodePhrases->rateSentence
}
