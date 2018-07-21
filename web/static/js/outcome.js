var btn
var arr = [2,3,4,5,6,7,8,9]

if (document.getElementById("click-me")) {
  btn = document.getElementById("click-me")
  var outcomeNodes = arr.map(i => document.getElementById(`outcome${i}`))
  outcomeNodes.map(outcomeNode => outcomeNode.classList.add("dn"))

  btn.addEventListener("click", function(){
    if (outcomeNodes.length !== 0) {
      outcomeNodes.shift().classList.remove("dn")
    }
  })
}
