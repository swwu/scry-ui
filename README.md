scry-ui
=======

UI widgets for the scry event visualization service. Currently provides a map
visualization.

Usage
-----
To "install":
```
npm install && node_modules/coffee-script/bin/coffee -c js
```
Then just include all these dependencies.
```
<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.9.1/jquery.min.js"></script>
<script src="http://localhost:3000/socket.io/socket.io.js"></script>
<script type="text/javascript"
  src="https://maps.googleapis.com/maps/api/js?key=AIzaSyDSExK6-t_4zCrL671_8wHHMUnreGJ3c8I&sensor=false">
<script src="js/jquery.scry-ui.js"></script>
<script>
  $('#map-element').scryMap({
    server: "SERVER_URI",
    labels: ["your","labels","here"]
  })
</script>
```

