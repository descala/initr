$(document).on('change', 'select#new_master', function(e) {
  var url = $(this).data('url');
  var val = $(this).val();

  if (val.length > 0) {
    $.ajax({
      url:      url,
      data:     "master_id="+val,
      type:     'post',
      dataType: 'text',
      async:    false
    }).done( function(html) {
      $('div#master_servers').html(html);
    }).fail( function(html) {
      alert('Something went wrong on ajax request...');
    });
  }

});

$(document).on('click', 'a.removemaster', function(e) {
  var url = $(this).data('url');

  $.ajax({
    url:      url,
    type:     'post',
    dataType: 'text',
    async:    false
  }).done( function(html) {
    $('div#master_servers').html(html);
  }).fail( function(html) {
    alert('Something went wrong on ajax request...');
  });

});
