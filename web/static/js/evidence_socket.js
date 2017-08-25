import socket from "./socket"

module.exports = (function () {
  var searchId = document.querySelector('#list-results').dataset.searchId;
  socket.connect()
  onReady(searchId, socket)
})();

function onReady (searchId, socket) {
  var evidenceChannel = socket.channel("evidence:" + searchId)
  publicationEvent(evidenceChannel);
  scrollEvent(socket, evidenceChannel);

  evidenceChannel.join()
  .receive("ok", resp => console.log("joined the evidence channel", resp))
  .receive("error", reason => console.log("join failed", reason))
}

function publicationEvent(channel) {
  var body = document.querySelector('body');
  body.addEventListener("click", function(e) {
    var classes = e.target.className
    if(classes.indexOf("publication") > -1) {
      // build payload to send to the channel
      var data = {
        search_id: e.target.dataset.searchId,
        url: e.target.getAttribute("href"),
        value: e.target.textContent,
        tripdatabase_id: e.target.dataset.tripdatabaseId
      };
      // send payload
      channel.push("evidence", data)
      .receive("error", function(err) {
        console.log(err);
      })
    }
  });
}

function scrollEvent(socket, channel) {
  var ready = true;
  var page = 1;
  var total = document.querySelector("#total-results").dataset.totalResults;
  var spinner = document.querySelector("#spinner");
  var listResults = document.querySelector("#list-results");
  var searchTerm = document.querySelector("#search_term").value;

  document.addEventListener('scroll', function() {
    if (ready && parseInt(total) > (20 * page) ) {
      if (document.body.scrollHeight == document.body.scrollTop + window.innerHeight) {
        spinner.style.display = "block";
        ready = false;
        channel.push("scroll", {term: searchTerm })
        .receive("ok", function(res) {
          listResults.insertAdjacentHTML('beforeend', res.content);
          ready = true;
          page = res.page;
          spinner.style.display = "none";
        })
        .receive("error", function(err) {
          console.log(err);
        })
      }
    }
  })
}
