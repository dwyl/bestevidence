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
    let outcomesAnsArr = outcomeAns.split(",")

    let interY = Number(outcomesAnsArr[0])
    let interN = Number(outcomesAnsArr[1])

    let controlY = Number(outcomesAnsArr[2])
    let controlN = Number(outcomesAnsArr[3])

    let interTotal = interY + interN
    let interRisk = interY / interTotal

    let controlTotal = controlY + controlN
    let controlRisk = controlY / controlTotal

    let arrMid = controlRisk - interRisk
    let arrLow = arrMid - 1.96 * Math.sqrt(interRisk * (1 - interRisk) / interTotal + controlRisk *(1 - controlRisk) / controlTotal)
    let arrHigh = arrMid + 1.96 * Math.sqrt(controlRisk * (1 - controlRisk) / controlTotal + interRisk * (1 - interRisk) / interTotal)

    // nntMid = Math.round((1 / arrMid), 0)
    // nntLow = Math.round((1 / arrHigh), 0)
    // nntHigh = Math.round((1 / arrLow), 0)

    let nntMid = 1
    let nntLow = 1
    let nntHigh = 1

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
