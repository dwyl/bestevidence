var share_question = document.getElementById("share-question")

var genOutcomeId = i => `pico_search_outcome_input_${i}`
var getElemValue = id => document.getElementById(id).value

var createOutcomeObj = (acc, currentVal, currentI, arr) => {
  let id = genOutcomeId(currentVal)
  acc[`Outcome ${currentVal}`] = getElemValue(id)
  return acc
}

if (share_question) {
  share_question.addEventListener("click", function() {
    var indexs = [1,2,3,4,5,6,7,8,9]

    var searchTerm = `Question: ${share_question.dataset.search}`;
    var lineBreak = "%0D%0A"
    var cc = "cc=bestevidencefeedback@gmail.com";
    var subject = "subject=New question"
    var note = `Background to question: ${share_question.dataset.note}`;

    var p = `Population: ${getElemValue("pico_search_p")}`
    var i = `Intervention: ${getElemValue("pico_search_i")}`
    var c = `Comparison: ${getElemValue("pico_search_c")}`

    var outcomesObj = indexs.reduce(createOutcomeObj, {})

    var outcomesStr = Object.entries(outcomesObj).reduce((acc, [key, value]) => {
      if (value == "") {
        return acc
      } else {
        return acc + `${key}: ${value}${lineBreak}`
      }
    }, "")

    if (outcomesStr == "") {
      outcomesStr = "No outcomes"
    }

    var position = `Current position: ${getElemValue("current-position")}`
    var prob = `Probability: ${getElemValue("probability")}`

    var body = `body=
${searchTerm}
${lineBreak}
${note}
${lineBreak}
${p}
${lineBreak}
${i}
${lineBreak}
${c}
${lineBreak}
${outcomesStr}
${lineBreak}
${position}
${lineBreak}
${prob}
${lineBreak}
Add any further comments...
`

    share_question.href = `mailto:?${cc}&${subject}&${body}`
  })
}
