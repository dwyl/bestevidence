module.exports = (function() {
  var publications = document.querySelectorAll(".publication");

  publications.forEach(function(publication) {
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
        if (request.readyState === 4 && request.status === 200) {
            console.log(request.responseText);
        }
      }
      request.send(JSON.stringify(data));
    })
  })
})()
