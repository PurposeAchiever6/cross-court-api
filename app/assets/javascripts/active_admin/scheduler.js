$(document).ready(() => {
  const path = window.location.pathname.replace(/\/+$/, "");

  if (["", "/admin", "/admin/scheduler"].includes(path)) {
    $("#active_admin_content").css("padding", 0);
    $("#scheduler-calendar").css("padding", "30px");
  }
});
