function unfollow_user(to_user_id,from_user_id){
	$.post("/unfollow_user/"+to_user_id,{"from_user_id":from_user_id},function(data, textStatus, jqXHR){
		if(data=="OK"){
			$("#follow")[0].outerHTML="<button class=\"btn btn-info\" id=\"follow\" onclick=\"follow_user('"+to_user_id+"','"+from_user_id+"');\">Follow</button>";
		}
	});
}

function follow_user(to_user_id,from_user_id){
	$.post("/follow_user/"+to_user_id,{"from_user_id":from_user_id},function(data, textStatus, jqXHR){
		if(data=="OK"){
			$("#follow")[0].outerHTML="<button class=\"btn btn-danger\" id=\"follow\" onclick=\"unfollow_user('"+to_user_id+"','"+from_user_id+"');\">Unfollow</button>";
		}
	});
}

function send_message(receiver_user_id){
	$( "#send_msg" ).dialog({
		resizable: false,
		height: 180,
		modal: true,
		buttons: {
			"Send": function() {
				$(this).dialog("close");
				$.post("/api/send_msg/"+receiver_user_id,{"format":"Markdown","body":$("#msg")[0].value},function(data, textStatus, jqXHR){
					if(data=="OK"){
						alert("Send success!");
					}
				});
			},
			Cancel: function() {
				$(this).dialog("close");
			}
		}
	});
}
