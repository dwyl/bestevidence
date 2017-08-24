import socket from "./socket"
import Evidence from "./evidence"

module.exports = (function () {
  Evidence.init(socket);
})();
