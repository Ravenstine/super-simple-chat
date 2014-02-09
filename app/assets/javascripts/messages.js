var source = new EventSource('/stream')

source.addEventListener('message', function(event){
	console.log("event: " + event)
	console.log("data: " + event.data)
	var data = JSON.parse(event.data)
	$('#messages').prepend('<p>' + data.body + '</p>')
	$('#new_message').val('')
})

$(document).on('click', '#send_message', function(e){
	e.preventDefault()
	$.ajax({
		type: 'POST',
		url: '/create',
		data: {'body': $('#new_message').val()}
	})
})