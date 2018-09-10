const baselineRiskInput = document.getElementById("baseline-risk-input")

var updateNNT = () => {
  let nntElem = document.getElementById("nnt-elem")
  let outcomeAns = document.getElementById("outcome-answers").value
  let nntValue

  if (outcomeAns == "") {
    nntValue = "You do not have any outcomes or you have not filled in calculate results";

  } else if (baselineRiskInput.value == "") {
    nntValue = "NNT: # (95%CI # to #)";

  } else if (isInt(baselineRiskInput.value)) {
    let baselineRiskDecimal = baselineRiskInput.value / 100

    let outcomesAnsArr = outcomeAns.split(",")

    let interY = Number(outcomesAnsArr[0])
    let interN = Number(outcomesAnsArr[1])

    let controlY = Number(outcomesAnsArr[2])
    let controlN = Number(outcomesAnsArr[3])

    let interTotal = interY + interN
    let interRisk = interY / interTotal

    let controlTotal = controlY + controlN
    let controlRisk = controlY / controlTotal

    let rrMid = interRisk / controlRisk
    let rrLow = rrMid * Math.exp(-1.96 * Math.sqrt((1 - interRisk) / (interTotal * interRisk) + (1 - controlRisk)/(controlTotal * controlRisk)))
    let rrHigh = rrMid * Math.exp(1.96 * Math.sqrt((1 - interRisk) / (interTotal * interRisk) + (1 - controlRisk)/(controlTotal * controlRisk)))

    let nntMid = Math.round(1 / (baselineRiskDecimal - baselineRiskDecimal * rrMid), 0)
    let nntLow = Math.round(1 / (baselineRiskDecimal - baselineRiskDecimal * rrLow), 0)
    let nntHigh = Math.round(1 / (baselineRiskDecimal - baselineRiskDecimal * rrHigh), 0)

    nntValue = `NNT: ${nntMid} (95%CI ${nntLow} to ${nntHigh})`;

  } else {
    nntValue = "Please enter a number";

  }

  nntElem.innerHTML = nntValue;
}

if (baselineRiskInput) {
  baselineRiskInput.oninput = () => updateNNT()
}

function isInt(value) {
  return !isNaN(value) &&
         parseInt(Number(value)) == value &&
         !isNaN(parseInt(value, 10)) &&
         value != "";
}
