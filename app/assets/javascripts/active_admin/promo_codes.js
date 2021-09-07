$(document).ready(function () {
  $("#promo_code_duration")
    .change(function () {
      const promoCodeValue = $(this).val();

      if (promoCodeValue === "repeating") {
        $("#promo_code_duration_in_months_input").show();
      } else {
        $("#promo_code_duration_in_months_input").hide();
      }
    })
    .change();

  const recurringProductIds = $("#new_promo_code").data("recurringProductIds");
  $("#promo_code_product_id")
    .change(function () {
      const productId = $(this).val();
      const isRecurring = recurringProductIds.includes(parseInt(productId));
      if (isRecurring) {
        $("#promo_code_duration_input").show();
      } else {
        $("#promo_code_duration_input").hide();
      }
    })
    .change();
});
