//= require active_admin/base
//= require recurring_select
//= require recurring_select/en

$(document).ready(function () {
  $("#product-unlimited")
    .change(function () {
      if (this.checked) {
        $("#product_credits")[0].value = -1;
        $("#product_credits_input").hide();
      } else {
        if ($("#product-unlimited").is(":enabled")) $("#product_credits")[0].value = 0;
        $("#product_credits_input").show();
      }
    })
    .change();
});
