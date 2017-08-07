module.exports = (function() {
  var body = document.querySelector('body');
  body.addEventListener("click", function(e) {
    var classes = e.target.className
    if(classes.indexOf("publication") > -1) {
      var data = {
        search_id: e.target.dataset.searchId,
        url: e.target.getAttribute("href"),
        value: e.target.textContent
      };

      var request = new XMLHttpRequest();
      request.open("POST", "/publication", true);
      request.setRequestHeader("Content-type", "application/json");

      request.onreadystatechange = function() {
        if (request.readyState === 4) {
          if (request.status === 200) {
            console.log(request.responseText);
          } else {
            console.log('STATUS: ', request.status, 'REQUEST: ', request);
          }
        }
      }
      request.send(JSON.stringify(data));
    }
  })
})()
