module.exports = {
  init(socket) {
    socket.connect()
    this.onReady("1", socket)
  },

  onReady(searchId, socket) {
    var evidenceChannel = socket.channel("evidence:" + searchId)

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
        evidenceChannel.push("evidence", data)
        .receive("error", function(err) {
          console.log(err);
        })
      }
    });

    evidenceChannel.on("evidence", function(response) {
      console.log("someone click on a publication");
    })


    evidenceChannel.join()
    .receive("ok", resp => console.log("joined the evidence channel", resp))
    .receive("error", reason => console.log("join failed", reason))
  }
}
