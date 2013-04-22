
$(function() {
  var labelElems = {}

  var removeLabelUI = function(label) {
    labelElems[label].remove();
    delete labelElems[label];
  };
  var addLabelUI = function(label, color) {
    labelElems[label] = $('<span><span class="color-dot">&#9679;</span> '+
        label+'</span>')
      .data("label", label)
      .on("click", function(e) {
        var label = $(this).data("label");
        $('#map-canvas').scryMap("deregister", [label]);
        removeLabelUI(label);
      });
    labelElems[label].find('.color-dot').css('color','#'+color)
    $('#registered-label-list').append(labelElems[label]);
  };

  $('#map-canvas').scryMap({
    labels: ["pe"],
    server: "http://scry-dispatcher.predictiveedge.com",
    events: {
      "registerLabel": function(label, obj) {
        addLabelUI(label, obj.color);
      },
      "deregisterLabel": function(label) {
        removeLabelUI(label);
      }
    }
  });

  $('#add-button').on("click", function(e) {
    var label;
    if (label = $('#label-input').val()) {
      $('#map-canvas').scryMap("register", [label]);
      $('#label-input').val("");
    }
  });
})

