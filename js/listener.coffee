
api_key = "AIzaSyDSExK6-t_4zCrL671_8wHHMUnreGJ3c8I"

socket = io.connect('http://localhost:3000')

socket.emit("register", ["cat2","cat3"])

socket.on("data", (data) ->
  console.log data
  addMarker(map, {lat:data.ll[0], lng:data.ll[1]})
)

addMarker = (map, latlng) ->
  marker = new google.maps.Marker({
    position: new google.maps.LatLng(latlng.lat, latlng.lng),
    map: map,
    title:"Hello World!"
  })
  window.setTimeout( =>
    marker.setMap(null)
  , 10000)

map = null
initialize = ->
  mapOptions = {
    center: new google.maps.LatLng(30, 0),
    zoom: 3,
    mapTypeId: google.maps.MapTypeId.HYBRID
  }
  map = new google.maps.Map(document.getElementById("map-canvas"),
    mapOptions)

  addMarker(map, {lat:37,lng:-122})

google.maps.event.addDomListener(window, 'load', initialize)
