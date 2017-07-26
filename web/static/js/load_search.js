module.exports = (function() {
  var searches = document.querySelectorAll(".search");
  var searchInput = document.querySelector('#search-input')

  for(var i = 0; i < searches.length; i++) {
    var search = searches[i]
    search.addEventListener("click", function(e) {
      searchInput.value = e.target.textContent;
      searchInput.focus();
    })
  }
})()
