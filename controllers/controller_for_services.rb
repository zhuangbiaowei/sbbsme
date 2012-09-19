get '/block/:id' do
	id=params[:id][1..-1]
	block=Block.where(:Id=>id).first
	block.to_json
end

get '/article/:id' do
	id=params[:id]
	main_block=Block.where(:Id=>id).first
	muid=main_block.AuthorId
	article={:main_block=>main_block,:tags=>[],:sub_blocks=>[],:left_blocks=>{},:right_blocks=>{},:users=>{muid=>user_avatar(muid)}}
	BlockTag.where(:BlockId=>main_block.Id).all.each do |bt|
		article[:tags]<<Tag.where(:Id=>bt.TagId).first
	end
	article[:left_blocks][id]=[]
	BlockLink.where(:RightId=>id).all.sort(Order: -1,Created_on: -1).each do |link|
		left_block=Block.where(:Id=>link.LeftId).first
		if (left_block.Type=="clone" and left_block.AuthorId==session[:current_user].Id) or left_block.Type!="clone"
			left_block.Type=link.Type
			article[:left_blocks][id]<<left_block
			article[:users][left_block.AuthorId]=user_avatar(left_block.AuthorId)
		end
	end
	article[:right_blocks][id]=[]
	BlockLink.where(:LeftId=>id).all.sort(Order: -1,Created_on: -1).each do |link|
		right_block=Block.where(:Id=>link.RightId).first
		if (right_block.Type=="clone" and right_block.AuthorId==session[:current_user].Id) or right_block.Type!="clone"
			right_block.Type=link.Type
			article[:right_blocks][id]<<right_block
			article[:users][right_block.AuthorId]=user_avatar(right_block.AuthorId)
		end
	end
	Block.where(:ParentId=>id).all.sort(Order: 1).each do |block|
		article[:sub_blocks]<<block
		article[:left_blocks][block.Id]=[]
		BlockLink.where(:RightId=>block.Id).all.sort(Order: -1,Created_on: -1).each do |link|
			left_block=Block.where(:Id=>link.LeftId).first
			if (left_block.Type=="clone" and left_block.AuthorId==session[:current_user].Id) or left_block.Type!="clone" 
				left_block.Type=link.Type
				article[:left_blocks][block.Id]<<left_block
				article[:users][left_block.AuthorId]=user_avatar(left_block.AuthorId)
			end
		end
		article[:right_blocks][block.Id]=[]
		BlockLink.where(:LeftId=>block.Id).all.sort(Order: -1,Created_on: -1).each do |link|
			right_block=Block.where(:Id=>link.RightId).first
			if (right_block.Type=="clone" and right_block.AuthorId==session[:current_user].Id) or right_block.Type!="clone"
				right_block.Type=link.Type
				article[:right_blocks][block.Id]<<right_block
				article[:users][right_block.AuthorId]=user_avatar(right_block.AuthorId)
			end
		end
	end
	article.to_json
end

post '/append_block/:id' do
	unless session[:current_user]
		return "please login"
	end
	id=params[:id][1..-1]
	text=params[:text]
	block=Block.where(:Id=>id).first
	user_id=session[:current_user].Id
	is_public=block.Public
	if block.ParentId
		pid=block.ParentId
		pblock=Block.where(:Id=>pid).first
		a_uid=pblock.AuthorId
		subject=pblock.Subject
		next_block=Block.where(:ParentId=>pid,:Order.gt=>block.Order).first
		if next_block
			order=(block.Order+next_block.Order)/2
		else
			order=block.Order+1
		end
		pblock.Updated_on=DateTime.now
		pblock.save
		is_public=pblock.Public
	else
		pid=block.Id
		subject=block.Subject
		a_uid=block.AuthorId
		first_block=Block.where(:ParentId=>pid).sort(Order: 1).first
		if first_block
			order=first_block.Order/2
		else
			order=1
		end
		block.Updated_on=DateTime.now
		block.save
	end
	if user_id.to_s!=a_uid.to_s
		return "another user"
	end
	new_block=Block.new
	new_block.Id=new_block.id.to_s
	new_block.ParentId=pid
	new_block.Subject=subject
	new_block.Body=text
	new_block.Order=order
	new_block.AuthorId=user_id
	new_block.Created_on=DateTime.now
	new_block.Type="sub"
	new_block.Public=is_public
	new_block.save
	cache_id="add_append_b"+id
	CachedContent.where(:Id=>cache_id,:AuthorId=>user_id).delete
	return "OK"
end

post '/comment_block/:id' do
	unless session[:current_user]
		return "please login"
	end
	id=params[:id][1..-1]
	text=params[:text]
	comment_type=params[:comment_type]
	comment_title=params[:comment_title]
	user_id=session[:current_user].Id
	block=Block.where(:Id=>id).first
	block.Updated_on=DateTime.now
	block.save
	new_block=Block.new
	new_block.Id=new_block.id.to_s
	new_block.Subject=comment_title
	new_block.Body=text
	new_block.Created_on=DateTime.now
	new_block.AuthorId=user_id
	new_block.Type="comment"
	new_block.Public=block.Public
	new_block.save
	link=BlockLink.new
	link.LeftId=id
	link.RightId=new_block.Id
	link.Type=comment_type
	link.Created_on=DateTime.now
	link.save
	cache_id="add_comment_b"+id
	CachedContent.where(:Id=>cache_id,:AuthorId=>user_id).delete
	return "OK"
end

post '/delete_block' do
	unless session[:current_user]
		return "please login"
	end
	id=params[:id][1..-1]
	block=Block.where(:Id=>id).first
	unless block.ParentId
		block.delete
		BlockLink.where(:LeftId=>id).delete
		BlockLink.where(:RightId=>id).delete
		Block.where(:ParentId=>id).all.each do |b|
			BlockLink.where(:LeftId=>b.Id).delete
			BlockLink.where(:RightId=>b.Id).delete
		end
		Block.where(:ParentId=>id).delete
		return "OK_ALL"
	else
		parent_block=Block.where(:Id=>block.ParentId).first
		parent_block.Updated_on=DateTime.now
		parent_block.save
		block.delete
		BlockLink.where(:LeftId=>id).delete
		BlockLink.where(:RightId=>id).delete
		return "OK"
	end
end

post '/edit_block/:id' do
	unless session[:current_user]
		return "please login"
	end
	id=params[:id][1..-1]
	block=Block.where(:Id=>id).first
	block.Body=params[:text]
	block.Updated_on=DateTime.now
	block.save
	if block.ParentId
		parent_block=Block.where(:Id=>block.ParentId).first
		parent_block.Updated_on=DateTime.now
		parent_block.save
	end
	cache_id="edit_b"+id
	CachedContent.where(:Id=>cache_id,:AuthorId=>block.AuthorId).delete
	return "OK"
end

post '/add_left_block/:id' do
	unless session[:current_user]
		return "please login"
	end
	id=params[:id][1..-1]
	block=Block.where(:Id=>id).first
	block.Updated_on=DateTime.now
	block.save
	if block.ParentId
		parent_block=Block.where(:Id=>block.ParentId).first
		parent_block.Updated_on=DateTime.now
		parent_block.save
	end	
	left_id=params[:left_id]
	comment_type=params[:comment_type]
	link=BlockLink.new
	link.LeftId=left_id
	link.RightId=id
	link.Type=comment_type
	link.Created_on=DateTime.now
	link.save
	return "OK"
end

post '/add_exist_block/:id' do
	unless session[:current_user]
		return "please login"
	end
	id=params[:id][1..-1]
	exist_id=params[:exist_id]
	block=Block.where(:Id=>id).first
	exist_block=Block.where(:Id=>exist_id).first
	user_id=session[:current_user].Id
	if user_id.to_s!=exist_block.AuthorId.to_s
		return "another user"
	end
	if block.ParentId
		pid=block.ParentId
		pblock=Block.where(:Id=>pid).first
		a_uid=pblock.AuthorId
		next_block=Block.where(:ParentId=>pid,:Order.gt=>block.Order).first
		if next_block
			order=(block.Order+next_block.Order)/2
		else
			order=block.Order+1
		end
		pblock.Updated_on=DateTime.now
		pblock.save
	else
		pid=block.Id
		a_uid=block.AuthorId
		first_block=Block.where(:ParentId=>pid).sort(Order: 1).first
		if first_block
			order=first_block.Order/2
		else
			order=1
		end
		block.Updated_on=DateTime.now
		block.save
	end
	if user_id.to_s!=a_uid.to_s
		return "another user"
	end	
	exist_block.ParentId=pid
	exist_block.Order=order
	exist_block.Updated_on=DateTime.now
	exist_block.Type="sub"
	exist_block.save
	return "OK"
end

post '/clone_block/:id' do
	unless session[:current_user]
		return "please login"
	end
	id=params[:id][1..-1]
	block=Block.where(:Id=>id).first
	link_type="#000"
	new_block=Block.new
	new_block.Id=new_block.id.to_s
	new_block.Subject=block.Subject
	new_block.Body=block.Body
	new_block.Created_on=DateTime.now
	new_block.AuthorId=session[:current_user].Id
	new_block.Type="clone"
	new_block.Public=block.Public
	new_block.save
	link=BlockLink.new
	link.LeftId=id
	link.RightId=new_block.Id
	link.Type=link_type
	link.Created_on=DateTime.now
	link.save
	return "OK"
end

post '/delete_link' do
	unless session[:current_user]
		return "please login"
	end
	id=params[:id][1..-1]
	left_id=params[:left_id][2..-1]
	block=Block.where(:Id=>id).first
	unless block.ParentId
		block.Updated_on=DateTime.now
		block.save
	else
		pblock=Block.where(:Id=>block.ParentId).first
		pblock.Updated_on=DateTime.now
		pblock.save
	end
	BlockLink.where(:LeftId=>left_id,:RightId=>id).delete
	return "OK"
end

get '/cache/:id' do	
	@current_user=session[:current_user]
	if @current_user
		content=CachedContent.where(:Id=>params[:id],:AuthorId=>@current_user.Id).first
		if content
			return content.to_json
		end
	end
	return ""
end

post '/cache/:id' do
	@current_user=session[:current_user]
	if @current_user
		CachedContent.where(:Id=>params[:id],:AuthorId=>@current_user.Id).delete
		content=CachedContent.new
		content.Id=params[:id]
		content.AuthorId=@current_user.Id
		content.Subject=params[:subject]
		content.Body=params[:body]
		content.save
	end
end

delete '/cache/:id' do
	@current_user=session[:current_user]
	if @current_user
		CachedContent.where(:Id=>params[:id],:AuthorId=>@current_user.Id).delete
	end
end