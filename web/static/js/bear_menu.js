var openNav = (elem) => elem.classList.remove("dn");
var closeNav = (elem) => elem.classList.add("dn");

if (document.getElementById("bear-nav")) {
  var nav = document.getElementById("bear-nav")
  var burgerMenu = document.getElementById("open-nav")
  var closeNavX = document.getElementById("close-bear-nav")

  burgerMenu.addEventListener("click", () => {
    if (burgerMenu.classList.contains("nav-is-open")) {
      burgerMenu.classList.remove("nav-is-open")
      closeNav(nav)
    } else {
      burgerMenu.classList.add("nav-is-open")
      openNav(nav)
    }
  })
  closeNavX.addEventListener("click", () => closeNav(nav))
}
