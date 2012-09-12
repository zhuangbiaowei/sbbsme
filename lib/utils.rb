def user_avatar(id)
	user=User.where(:Id=>id).first
	if user
		return "<a href=\"/user/"+user.Id+"\"><img src=\"#{user.AvatarURL}\" alt=\"#{user.Name}\" width=\"16\" height=\"16\" border=\"0\"></a>"
	else
		""
	end
end
