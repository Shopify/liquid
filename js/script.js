$menuButton = $(".menu-button");
$sidebar = $(".sidebar");
$contentOverlay = $(".content__overlay");


$(document).ready(function() {

  $menuButton.add($contentOverlay).on("click", function() {
    $sidebar.toggleClass("sidebar--is-visible");
    $contentOverlay.toggleClass("content__overlay--is-active");
  });
})
