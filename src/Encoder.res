module Natural = {
  type porterStemmer = {stem: string => string}
  @module("natural") external porterStemmer: porterStemmer = "PorterStemmer"
}

type feedbackItem = {"great": int, "good": int, "ok": int, "bad": int, "meaningless": int}
type trainingItem = {"input": string, "output": feedbackItem}

@scope("[].concat") @val
external flatten: array<array<'a>> => array<'a> = "apply"

let getTokenizedArr = item => {
  let tokens = Js.String.split(item["input"], " ")

  Belt.Array.map(tokens, token => {
    Natural.porterStemmer.stem(token)
  })
}

let getDictionary = (self, item: string, pos: int) => {
  Js.Array.indexOf(item, self) === pos
}

let getEncoder = dictionary => {
  phrase => {
    let phraseTokens = Js.String.split(phrase, " ")
    let encodedPhrase = Belt.Array.map(dictionary, word =>
      Js.Array.includes(word, phraseTokens) ? 1 : 0
    )
    encodedPhrase
  }
}

let encodeTrainingSet = encodeFn => {
  item => {
    let encodedValue = encodeFn(item["input"])
    {"input": encodedValue, "output": item["output"]}
  }
}

@module external trainingData: array<trainingItem> = "ygo-text-model/trainingData"

let tokenizedArray = Belt.Array.map(trainingData, getTokenizedArr)
let flattenedArray = flatten(tokenizedArray)
let dictionary = Js.Array.filteri(getDictionary(flattenedArray), flattenedArray)
let encode = getEncoder(dictionary)
