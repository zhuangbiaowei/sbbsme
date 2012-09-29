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