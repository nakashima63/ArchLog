document.addEventListener("DOMContentLoaded", function () {
  var links = document.querySelectorAll("a[href^='http']");
  var siteHost = location.hostname;
  links.forEach(function (link) {
    if (link.hostname !== siteHost) {
      link.setAttribute("target", "_blank");
      link.setAttribute("rel", "noopener noreferrer");
    }
  });
});
