@main_ready = () ->
  bootbox.animate(false)
  bootbox.backdrop(false)
  $("select[rel=chosen]").chosen();
  $(".chosen").chosen();

