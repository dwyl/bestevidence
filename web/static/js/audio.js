$( document ).ready(function() {
  var player = document.getElementById('player');

  var handleSuccess = function (stream) {
    if (window.URL) {
      player.src = window.URL.createObjectURL(stream);
    } else {
      player.src = stream;
    }
  };

  navigator.mediaDevices.getUserMedia({ audio: true, video: false }).then(handleSuccess)
});
