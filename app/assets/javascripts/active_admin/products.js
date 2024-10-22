$(document).ready(function () {
  $("#product_product_type")
    .change(function () {
      const productTypeValue = $(this).val();

      if (productTypeValue === "recurring") {
        $("#product_season_pass_input").hide();
        $("#product_price_for_members_input").hide();
        $("#product_price_for_first_timers_no_free_session_input").hide();
        $("#product_referral_cc_cash_input").show();
        $("#product-sessions-unlimited-container").show();
        $("#product-skill-sessions-unlimited-container").show();
        $("#product_skill_session_credits_input").show();
        $("#product_max_rollover_credits_input").show();
        $("#product_free_pauses_per_year_input").show();
        $("#product_highlights_input").show();
        $("#product_free_jersey_rental_input").show();
        $("#product_free_towel_rental_input").show();
        $("#product_waitlist_priority_input").show();
        $("#product_no_booking_charge_feature_input").show();
        $("#product_no_booking_charge_feature_hours_input").show();
        $("#product_credits_expiration_days_input").hide();
      } else {
        $("#product_season_pass_input").show();
        $("#product_price_for_members_input").show();
        $("#product_price_for_first_timers_no_free_session_input").show();
        $("#product_referral_cc_cash_input").hide();
        $("#product-sessions-unlimited-container").hide();
        $("#product-skill-sessions-unlimited-container").hide();
        $("#product_skill_session_credits_input").hide();
        $("#product_max_rollover_credits_input").hide();
        $("#product_free_pauses_per_year_input").hide();
        $("#product_highlights_input").hide();
        $("#product_free_jersey_rental_input").hide();
        $("#product_free_towel_rental_input").hide();
        $("#product_waitlist_priority_input").hide();
        $("#product_no_booking_charge_feature_input").hide();
        $("#product_no_booking_charge_feature_hours_input").hide();
        $("#product_credits_expiration_days_input").show();
      }
    })
    .change();

  $("#product-sessions-unlimited")
    .change(function () {
      if (this.checked) {
        $("#product_credits")[0].value = -1;
        $("#product_credits_input").hide();
        $("#product_max_rollover_credits")[0].value = null;
        $("#product_max_rollover_credits_input").hide();
      } else {
        $("#product_credits_input").show();
        $("#product_max_rollover_credits_input").show();
      }
    })
    .change();

  $("#product-skill-sessions-unlimited")
    .change(function () {
      if (this.checked) {
        $("#product_skill_session_credits")[0].value = -1;
        $("#product_skill_session_credits_input").hide();
      } else {
        $("#product_skill_session_credits_input").show();
      }
    })
    .change();
});
