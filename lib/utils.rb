require 'redis'

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

def send_message(user_id,msg)
	r=Redis.new
	r.rpush(user_id,Marshal.dump(msg))
	r.incr("#{user_id}_count")
end

def update_tags(id,tags)
	clean_tag(id)
	tags.split(",").each do |tag_name|
		tag=Tag.where(:Name=>tag_name).first
		unless tag
			tag=Tag.new
			tag.Name=tag_name
			tag.Id=tag._id
			tag.BlockCount=1
			tag.save
		else
			tag.BlockCount=tag.BlockCount+1
			tag.save
		end
		bt=BlockTag.new
		bt.BlockId=id
		bt.TagId=tag.Id
		bt.save
	end	
end

def clean_tag(block_id)
	BlockTag.where(:BlockId=>block_id).each do |bt|
		tag=Tag.where(:Id=>bt.TagId).first
		if tag
			if tag.BlockCount==1
				tag.delete
			else
				tag.BlockCount=tag.BlockCount-1
				tag.save
			end
		end
	end
	BlockTag.where(:BlockId=>block_id).delete
end
