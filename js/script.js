var menuButton = document.querySelector('.menu-button');
var sidebar = document.querySelector('.sidebar');
var contentOverlay = document.querySelector('.content__overlay');

document.addEventListener('DOMContentLoaded', function() {

  menuButton.addEventListener('click', function() {
    sidebar.classList.toggle('sidebar--is-visible');
    contentOverlay.classList.toggle('content__overlay--is-active');
  });

  contentOverlay.addEventListener('click', function() {
    sidebar.classList.toggle('sidebar--is-visible');
    contentOverlay.classList.toggle('content__overlay--is-active');
  });

});
