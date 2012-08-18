def user_avatar(id)
	user=User.where(:Id=>id).first
	if user
		return "<img src=\"#{user.AvatarURL}\" alt=\"#{user.Name}\" width=\"16\" height=\"16\">"
	else
		""
	end
end