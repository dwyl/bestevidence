module.exports = (function() {
  var publications = document.querySelectorAll(".publication");

  for(var i = 0; i < publications.length; i++) {
    var publication = publications[i]
    publication.addEventListener("click", function(e) {
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
    })
  }
})()
