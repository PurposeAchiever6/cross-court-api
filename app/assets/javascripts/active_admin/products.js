$(document).ready(function () {
  $("#product-unlimited")
    .change(function () {
      if (this.checked) {
        $("#product_credits")[0].value = -1;
        $("#product_credits_input").hide();
      } else {
        if ($("#product-unlimited").is(":enabled")) {
          $("#product_credits")[0].value = 0;
        }
        $("#product_credits_input").show();
      }
    })
    .change();

  $("#product_product_type")
    .change(function () {
      const productTypeValue = $(this).val();

      if (productTypeValue === "recurring") {
        $("#product_price_for_members_input").hide();
      } else {
        $("#product_price_for_members_input").show();
      }
    })
    .change();
});
