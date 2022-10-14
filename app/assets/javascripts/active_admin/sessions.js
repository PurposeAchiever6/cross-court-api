$(document).ready(function () {
  $("#session_skill_session")
    .change(function () {
      if (this.checked) {
        $("#session_default_coach_input").show();
        $("#session_default_referee_id").val(null).trigger("change");
        $("#session_default_referee_input").hide();
        $("#session_default_sem_id").val(null).trigger("change");
        $("#session_default_sem_input").hide();
      } else {
        $("#session_default_coach_id").val(null).trigger("change");
        $("#session_default_coach_input").hide();
        $("#session_default_referee_input").show();
        $("#session_default_sem_input").show();
      }
    })
    .change();

  $("#session_is_open_club")
    .change(function () {
      if (this.checked) {
        $("#session_max_capacity").val(null).trigger("change");
        $("#session_max_capacity_input").hide();
      } else {
        $("#session_max_capacity_input").show();
      }
    })
    .change();
});
