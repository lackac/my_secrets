$(function() {
  $("#user")
    .focus(function(e) {
      if ($(this).val() == "felhasználónév") {
        $(this).val("").removeClass('placeholder');
      }
    })
    .blur(function(e) {
      if (!$(this).val()) {
        $(this).val("felhasználónév").addClass('placeholder');
      }
    })
    .val(function(i, val) {
      if (!val) $(this).addClass('placeholder');
      return val || "felhasználónév";
    });
  var pass = $('#pass'), passPlaceholder = $('<span></span>', {
    css: {
      position: 'absolute', display: 'inline', margin: '4px 6px',
      color: '#888',
      'font-family': pass.css('font-family'),
      'font-size': pass.css('font-size'),
      'font-weight': pass.css('font-weight')
    },
    text: 'jelszó',
    click: function(e) {
      e.preventDefault();
      $('#pass').focus();
    }
  });
  pass.before(passPlaceholder)
      .focus(function(e) {
        passPlaceholder.hide();
      })
      .blur(function(e) {
        if (!$(this).val()) {
          passPlaceholder.show();
        }
      });
  if (pass.val()) {
    passPlaceholder.hide();
  }
});
