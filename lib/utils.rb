def user_avatar(id)
	user=User.where(:Id=>id).first
	if user
		return "<a href=\"/user/"+user.Id+"\"><img src=\"#{user.AvatarURL}\" alt=\"#{user.Name}\" width=\"16\" height=\"16\" border=\"0\"></a>"
	else
		""
	end
end

def re_count_right_block(re_count_id_list)
	re_count_id_list.each do |id|
		b=Block.where(:Id=>id).first
		b.RightBlockCount=BlockLink.where(:LeftId=>id).count
		b.save
	end
end

def get_msg_count(user)
	if user
		r=Redis.new
		return r.exists("#{user.Id}_count")? r.get("#{user.Id}_count") : 0
	else
		return 0
	end
end

def is_followed(from_id,to_id)
	return Watch.where(:UserId=>from_id,:WatchedId=>to_id,:WatchType=>'user').first
end