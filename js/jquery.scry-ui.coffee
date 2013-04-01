(($) ->
  $.fn.extend({
    scryMap: (opts) ->
      default_opts = {
        api_key: "AIzaSyDSExK6-t_4zCrL671_8wHHMUnreGJ3c8I"
        labels: ["event"]
        server: 'http://localhost:3000'
      }

      opts = $.extend(default_opts, opts)

      socket = io.connect(opts.server)
      map = null

      # register us for the given labels
      socket.emit("register", opts.labels)
      socket.on("data", (data) ->
        addMarker(map, {lat:data.ll[0], lng:data.ll[1]})
      )

      mapOptions = {
        center: new google.maps.LatLng(30, 0),
        zoom: 3,
        mapTypeId: google.maps.MapTypeId.HYBRID
      }
      map = new google.maps.Map(@[0], mapOptions)

      addMarker = (map, latlng) ->
        marker = new google.maps.Marker({
          position: new google.maps.LatLng(latlng.lat, latlng.lng),
          map: map,
          title:"Hello World!"
        })
        window.setTimeout( =>
          marker.setMap(null)
        , 10000)

  })
)(jQuery)
