/*
* Add event listener which detect if a user is at the bottom of the results page
* load new results in page
*/
module.exports = (function() {
  var ready = true;
  var sectionResults = document.querySelector("#spinner");
  var listResults = document.querySelector("#list-results");
  var searchTerm = document.querySelector("#search_term").value;
  // var searchId = document.querySelector("#search-id").value;
  var total = document.querySelector("#total-results").dataset.totalResults
  var page = 1;
  var url = "";

  // document.addEventListener('scroll', function() {
  //   if (ready && total > (20 * page)) {
  //     if (document.body.scrollHeight == document.body.scrollTop + window.innerHeight) {
  //       ready = false;
  //       spinner.style.display = "block";
  //
  //       var request = new XMLHttpRequest();
  //       url = "/load?term=" + searchTerm + "&page=" + page + "&searchId=" + searchId
  //       request.open("GET", url, true);
  //       request.setRequestHeader("Content-type", "application/json");
  //
  //       request.onreadystatechange = function() {
  //         if (request.readyState === 4) {
  //           if (request.status === 200) {
  //             var data = JSON.parse(request.responseText)
  //             listResults.insertAdjacentHTML('beforeend', data.data);
  //             spinner.style.display = "none";
  //             page += 1;
  //             ready = true;
  //           } else {
  //             console.log('STATUS: ', request.status, 'REQUEST: ', request);
  //           }
  //         }
  //       }
  //       request.send(null);
  //     }
  //   }
  // })
})()
