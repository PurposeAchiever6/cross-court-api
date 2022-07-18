$(document).ready(function () {
  $("#product-sessions-unlimited")
    .change(function () {
      if (this.checked) {
        $("#product_credits")[0].value = -1;
        $("#product_credits_input").hide();
      } else {
        if ($("#product-sessions-unlimited").is(":enabled")) {
          $("#product_credits")[0].value = 0;
        }
        $("#product_credits_input").show();
      }
    })
    .change();

  $("#product-skill-sessions-unlimited")
    .change(function () {
      if (this.checked) {
        $("#product_skill_session_credits")[0].value = -1;
        $("#product_skill_session_credits_input").hide();
      } else {
        if ($("#product-skill-sessions-unlimited").is(":enabled")) {
          $("#product_skill_session_credits")[0].value = 0;
        }
        $("#product_skill_session_credits_input").show();
      }
    })
    .change();

  $("#product_product_type")
    .change(function () {
      const productTypeValue = $(this).val();

      if (productTypeValue === "recurring") {
        $("#product_price_for_members_input").hide();
        $("#product_price_for_first_timers_no_free_session_input").hide();
        $("#product_referral_cc_cash_input").show();
      } else {
        $("#product_price_for_members_input").show();
        $("#product_price_for_first_timers_no_free_session_input").show();
        $("#product_referral_cc_cash_input").hide();
      }
    })
    .change();
});
