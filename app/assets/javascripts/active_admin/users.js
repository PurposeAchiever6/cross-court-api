$(document).ready(function () {
  $("#user_is_coach, #user_is_referee, #user_is_sem")
    .change(function () {
      if (
        $("#user_is_coach").is(":checked") ||
        $("#user_is_referee").is(":checked") ||
        $("#user_is_sem").is(":checked")
      ) {
        $("#user_bio_input").show();
      } else {
        $("#user_bio").val(null).trigger("change");
        $("#user_bio_input").hide();
      }
    })
    .change();
});
