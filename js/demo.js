
$(function() {
  var labelElems = {}

  var removeLabelUI = function(label) {
    labelElems[label].remove();
    delete labelElems[label];
  };
  var addLabelUI = function(label) {
    labelElems[label] = $('<span>'+label+'</span>')
      .data("label", label)
      .on("click", function(e) {
        var label = $(this).data("label");
        $('#map-canvas').scryMap("deregister", [label]);
        removeLabelUI(label);
      });
    $('#registered-label-list').append(labelElems[label]);
  };

  $('#map-canvas').scryMap({
    labels: ["pe"],
    server: "http://scry-dispatcher.predictiveedge.com",
    events: {
      "registerLabel": function(label) {
        addLabelUI(label);
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

