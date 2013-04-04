(($) ->

  toRadians = (deg) -> deg * Math.PI / 180
  toDegrees = (rad) -> rad * 180 / Math.PI

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

    t = time.getUTCHours()
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
    scryMap: (opts) ->
      default_opts = {
        labels: ["event"]
        server: 'http://localhost:3000'
        mark_lifetime: 20000
        showdaynight: true
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

      addMarker = (map, latlng) ->
        marker = new google.maps.Marker({
          position: new google.maps.LatLng(latlng.lat, latlng.lng),
          map: map,
          title:"Hello World!"
        })
        window.setTimeout( =>
          marker.setMap(null)
        , opts.mark_lifetime)

  })
)(jQuery)
