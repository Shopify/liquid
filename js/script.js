var menuButton = document.querySelector('.menu-button')
var sidebar = document.querySelector('.sidebar')
var sidebarNav = document.querySelector('.sidebar__nav')
var contentOverlay = document.querySelector('.content__overlay')

function toggleSidebar() {
  sidebar.classList.toggle('sidebar--is-visible')
  contentOverlay.classList.toggle('content__overlay--is-active')
}

function scrollToFilter(e, filterId) {
  var fi = document.getElementById(filterId)
  fi.scrollIntoView()
  sidebarNav.scrollTo(sidebarNav.scrollLeft, sidebarNav.scrollTop - 150 + fi.getBoundingClientRect().top)
  sidebar.getBoundingClientRect().left < 0 && toggleSidebar()
  e.preventDefault()
  return false
}

document.addEventListener('DOMContentLoaded', function () {
  menuButton.addEventListener('click', toggleSidebar)
  contentOverlay.addEventListener('click', toggleSidebar)
})
