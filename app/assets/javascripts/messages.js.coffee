source = new EventSource("/stream")
source.addEventListener "message", (event) ->
  console.log "event: " + event
  console.log "data: " + event.data
  data = JSON.parse(event.data)
  $("#messages").prepend "<p>" + data.body + "</p>"
  $("#new_message").val ""

 source.addEventListener "heartbeat", (event) ->
  console.log "thump"

$(document).on "click", "#send_message", (e) ->
  e.preventDefault()
  $.ajax
    type: "POST"
    url: "/create"
    data:
      body: $("#new_message").val()