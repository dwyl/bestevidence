var outcomesDivCollection = document.getElementsByClassName("outcomes-div")

window.onload = () => {
  if (outcomesDivCollection.length !== 0) {
    for (var i = 0; i < outcomesDivCollection.length; i++) {
      var interObj = createInterOrControlObj("intervention", i + 1)
      var controlObj = createInterOrControlObj("control", i + 1)
      var stats = createStats(i + 1)

      updateAllStats(interObj, controlObj, stats)
      addOninputs(i + 1)
    }
  }
}

function createInterOrControlObj(str, i) {
  return {
    yes: document.getElementById(`${str}-yes-${i}`),
    no: document.getElementById(`${str}-no-${i}`),
    total: document.getElementById(`${str}-total-${i}`),
    risk: document.getElementById(`${str}-risk-${i}`)
  }
}

function createStatTypeObj(str, i) {
  return {
    mid: document.getElementById(`${str}-mid-${i}`),
    low: document.getElementById(`${str}-low-${i}`),
    high: document.getElementById(`${str}-high-${i}`),
    inputMid: document.getElementById(`${str}-mid-input-${i}`),
    inputLow: document.getElementById(`${str}-low-input-${i}`),
    inputHigh: document.getElementById(`${str}-high-input-${i}`)
  }
}

function createStats(i) {
  return {
    arr: createStatTypeObj("arr", i),
    rr: createStatTypeObj("rr", i),
    rrr: createStatTypeObj("rrr", i),
    or: createStatTypeObj("or", i),
    nnt: createStatTypeObj("nnt", i)
  }
}

function addOninputs(i) {
  var interObj = createInterOrControlObj("intervention", i)
  var controlObj = createInterOrControlObj("control", i)
  var stats = createStats(i)

  interObj.yes.oninput = () => updateAllStats(interObj, controlObj, stats)
  interObj.no.oninput = () => updateAllStats(interObj, controlObj, stats)
  controlObj.yes.oninput = () => updateAllStats(interObj, controlObj, stats)
  controlObj.no.oninput = () => updateAllStats(interObj, controlObj, stats)
}

function updateAllStats(interObj, controlObj, stats) {
  let interYes
  let interNo

  let controlYes
  let controlNo

  let interTotal
  let interRisk
  let controlTotal
  let controlRisk

  let arrMid
  let arrLow
  let arrHigh

  let rrMid
  let rrLow
  let rrHigh

  let rrrMid
  let rrrLow
  let rrrHigh

  let orMid
  let orLow
  let orHigh

  let nntMid
  let nntLow
  let nntHigh

  // intervention total and risk
  if (isInt(interObj.yes.value) && isInt(interObj.no.value)) {
    interYes = Number(interObj.yes.value)
    interNo = Number(interObj.no.value)
    interTotal = interYes + interNo
    interRisk = interYes / interTotal
    interObj.total.innerHTML = interTotal
    interObj.risk.innerHTML = interRisk.toFixed(2)
  } else {
    interObj.total.innerHTML = ""
    interObj.risk.innerHTML = ""
  }

  // control total and risk
  if (isInt(controlObj.yes.value) && isInt(controlObj.no.value)) {
    controlYes = Number(controlObj.yes.value)
    controlNo = Number(controlObj.no.value)
    controlTotal = controlYes + controlNo
    controlRisk = controlYes / controlTotal
    controlObj.total.innerHTML = controlTotal
    controlObj.risk.innerHTML = controlRisk.toFixed(2)
  } else {
    controlObj.total.innerHTML = ""
    controlObj.risk.innerHTML = ""
  }

  if (isInt(interTotal && controlTotal)) {

    arrMid = controlRisk - interRisk
    arrLow = arrMid - 1.96 * Math.sqrt(interRisk * (1 - interRisk) / interTotal + controlRisk *(1 - controlRisk) / controlTotal)
    arrHigh = arrMid + 1.96 * Math.sqrt(controlRisk * (1 - controlRisk) / controlTotal + interRisk * (1 - interRisk) / interTotal)

    rrMid = interRisk / controlRisk
    rrLow = rrMid * Math.exp(-1.96 * Math.sqrt((1 - interRisk) / (interTotal * interRisk) + (1 - controlRisk)/(controlTotal * controlRisk)))
    rrHigh = rrMid * Math.exp(1.96 * Math.sqrt((1 - interRisk) / (interTotal * interRisk) + (1 - controlRisk)/(controlTotal * controlRisk)))

    rrrMid = arrMid / controlRisk
    rrrLow = arrLow / controlRisk
    rrrHigh = arrHigh / controlRisk

    orMid = (interYes * controlNo) / (controlYes * interNo)
    orLow = orMid * Math.exp(-1.96 * Math.sqrt(1 / interYes + 1 / interNo + 1 / controlYes + 1 / controlNo))
    orHigh = orMid * Math.exp(1.96 * Math.sqrt(1 / interYes + 1 / interNo + 1 / controlYes + 1 / controlNo))

    nntMid = Math.round((1 / arrMid), 0)
    nntLow = Math.round((1 / arrHigh), 0)
    nntHigh = Math.round((1 / arrLow), 0)

  // ARR
    fillStatValues(stats, arrMid, arrLow, arrHigh, "arr", toPercent)

  // RR
    fillStatValuesToFixed(stats, rrMid, rrLow, rrHigh, "rr")

  // RRR
    fillStatValues(stats, rrrMid, rrrLow, rrrHigh, "rrr", toPercent)

  // OR
    fillStatValuesToFixed(stats, orMid, orLow, orHigh, "or")

  // NNT
    stats.nnt.mid.innerHTML = nntMid
    stats.nnt.low.innerHTML = nntLow
    stats.nnt.high.innerHTML = nntHigh
    stats.nnt.inputMid.value = nntMid
    stats.nnt.inputLow.value = nntLow
    stats.nnt.inputHigh.value = nntHigh

  } else {
    makeInnerHTMLEmpty(stats, arrMid, arrLow, arrHigh, "arr")
    makeInnerHTMLEmpty(stats, rrMid, rrLow, rrHigh, "rr")
    makeInnerHTMLEmpty(stats, rrrMid, rrrLow, rrrHigh, "rrr")
    makeInnerHTMLEmpty(stats, orMid, orLow, orHigh, "or")
    makeInnerHTMLEmpty(stats, nntMid, nntLow, nntHigh, "nnt")
  }
}

function toPercent(num) {
  return (num * 100).toFixed(2) + "%"
}

function isInt(value) {
  return !isNaN(value) &&
         parseInt(Number(value)) == value &&
         !isNaN(parseInt(value, 10)) &&
         value != "";
}

function fillStatValuesToFixed(stats, mid, low, high, key){
  var array = [mid, low, high].map((x) => x.toFixed(2))
  stats[key].mid.innerHTML = array[0]
  stats[key].low.innerHTML = array[1]
  stats[key].high.innerHTML = array[2]
  stats[key].inputMid.value = array[0]
  stats[key].inputLow.value = array[1]
  stats[key].inputHigh.value = array[2]
}

function fillStatValues(stats, mid, low, high, key, callback){
  var array = [mid, low, high].map((x) => callback(x))
  stats[key].mid.innerHTML = array[0]
  stats[key].low.innerHTML = array[1]
  stats[key].high.innerHTML = array[2]
  stats[key].inputMid.value = array[0]
  stats[key].inputLow.value = array[1]
  stats[key].inputHigh.value = array[2]
}

function makeInnerHTMLEmpty(stats, mid, low, high, key){
  stats[key].mid.innerHTML = ""
  stats[key].low.innerHTML = ""
  stats[key].high.innerHTML = ""
}
