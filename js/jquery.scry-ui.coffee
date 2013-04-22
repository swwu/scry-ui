(($) ->

  toRadians = (deg) -> deg * Math.PI / 180
  toDegrees = (rad) -> rad * 180 / Math.PI

  colors = (i) ->
    return [
      '009ada', # blue
      '8fc53b', # green
      'f7953e', # orange
      'e44793', # pink
      'a04734', # purple
      'f73e3e', # red
      '14e3e1', # teal
      '0048da', # royal blue
      'f4ed3b', # yellow
      '768292', # slate

      '33cc33',
      '0099ff',
      'ff00ff',
      'ff9933',
      '00ff99',
      '3366ff',
      'ff3399',
      'ffff00',
      '33cccc',
      '9966ff',
      'ff5050',
      '99ff33'
    ][i]

  DAY_MS = 86400000

  getMapTerminator = (time) ->
    if not time
      time = new Date()
    yearStart = new Date(time.getFullYear(), 0, 0)
    d = Math.floor((time-yearStart)/DAY_MS)
    M = -3.6 + 0.9856 * d
    v = M + 1.9 * Math.sin(toRadians(M))
    lambda = v + 102.9
    decl = 22.8 * Math.sin(toRadians(lambda)) + 0.6 * Math.pow(Math.sin(toRadians(lambda)),3)

    t = time.getUTCHours() + time.getUTCMinutes()/60
    b = decl
    l = -15 * t
    termFn = (psi) ->
      B = toDegrees(Math.asin(Math.cos(toRadians(b)) * Math.sin(psi)))
      x = -Math.cos(toRadians(l)) * Math.sin(toRadians(b)) * Math.sin(psi) - Math.sin(toRadians(l)) * Math.cos(psi)
      y = -Math.sin(toRadians(l)) * Math.sin(toRadians(b)) * Math.sin(psi) + Math.cos(toRadians(l)) * Math.cos(psi)
      L = toDegrees(Math.atan2(y, x))
      return [B,L]

    points = []
    curve = for psi in (toRadians(x) for x in [0..360])
      ll = termFn(psi)
      new google.maps.LatLng(ll[0],ll[1])
    points = points.concat(curve)

    curveback = for psi in (toRadians(x*4) for x in [360/4..0] by -1)
      ll = termFn(psi)
      new google.maps.LatLng(-85,ll[1])
    points = points.concat(curveback)

    return new google.maps.Polygon({
      paths: points
      strokeOpacity: 0
      strokeWeight: 0
      fillColor: "black"
      fillOpacity: 0.3
    })


  $.fn.extend({
    scryMap: (args...) ->
      events = {}

      colorMapping = {}

      addLabels = (labels) ->
        socket.emit("register", labels)
        for label in labels
          colorMapping[label] = colors((k for k of colorMapping).length)
          events.registerLabel?(label,{color:colorMapping[label]})
      removeLabels = (labels) ->
        socket.emit("deregister", labels)
        for label in labels
          delete colorMapping[label]
          events.deregisterLabel?(label)

      if $.isPlainObject(args[0])
        opts = args[0]
        default_opts = {
          labels: ["event"]
          server: 'http://localhost:3000'
          mark_lifetime: 20000
          label_sort_priority: (a,b) ->
             b.split('@').length - a.split('@').length
          showdaynight: true
          events: {
            "registerLabel": null
            "deregisterLabel": null
          }
        }

        opts = $.extend(default_opts, opts)

        events = $.extend(events, opts.events)

        socket = io.connect(opts.server)
        map = null

        # register us for the given labels
        addLabels(opts.labels)
        socket.on("data", (data) ->
          addMarker(
            map,
            {lat:data.ll[0], lng:data.ll[1]},
            colorMapping[data.labels.sort(opts.label_sort_priority)[0]]
          )
        )

        mapOptions = {
          center: new google.maps.LatLng(30, 0),
          zoom: 3,
          mapTypeId: google.maps.MapTypeId.HYBRID
        }
        map = new google.maps.Map(@[0], mapOptions)

        addTerminator = ->
          poly = getMapTerminator()
          poly.setMap(map)
          setInterval( =>
            poly?.setMap(null)
            poly = getMapTerminator()
            poly.setMap(map)
          , 30000)

        if opts.showdaynight
          addTerminator()

        addMarker = (map, latlng, color) ->
          marker = new google.maps.Marker({
            icon: new google.maps.MarkerImage(
              "http://chart.apis.google.com/chart?chst=d_map_pin_letter&chld=%E2%80%A2|#{color}",
              new google.maps.Size(21, 34),
              new google.maps.Point(0,0),
              new google.maps.Point(10, 34)
            )
            shadow: new google.maps.MarkerImage(
              "http://chart.apis.google.com/chart?chst=d_map_pin_shadow",
              new google.maps.Size(40, 37),
              new google.maps.Point(0, 0),
              new google.maps.Point(12, 35)
            )
            position: new google.maps.LatLng(latlng.lat, latlng.lng),
            map: map,
            title:""
          })
          window.setTimeout( =>
            marker.setMap(null)
          , opts.mark_lifetime)

        @data("opts", opts)
        @data("events", events)
        @data("socket", socket)
        @data("map", map)
        @data("map", colorMapping)
      else
        opts = @data("opts")
        events = @data("events")
        socket = @data("socket")
        map = @data("map")
        colorMapping = @data("map")

        if $.type(args[0]) == "string"
          verb = args[0]

          if verb == "register" and $.isArray(args[1])
            addLabels(args[1])
          if verb == "deregister" and $.isArray(args[1])
            removeLabels(args[1])

  })
)(jQuery)
