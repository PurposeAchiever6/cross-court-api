$(document).ready(() => {
  const path = window.location.pathname.replace(/\/+$/, "");
  if (path === "/admin" || path === "/admin/scheduler") {
    $("#active_admin_content").css("padding", 0);
    $("#scheduler-calendar").css("padding", "30px");
  }
});
