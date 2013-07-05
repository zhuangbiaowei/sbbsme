get '/api/login/:uid/:name' do
    uid = params[:uid]
    name = params[:name]
    avatar=params[:avatar]
    type=params[:account_type]
    db_user=User.where(:Id=>uid).first
    unless db_user
        db_user=User.new
        db_user.Id=uid
        db_user.Name=name
        db_user.AvatarURL=avatar
        db_user.Type=type
        db_user.save
    end
    session[:current_user]=db_user
    return db_user.to_json
end

get '/api/:provider/callback' do
	if params[:provider]=='weibo'
		code=params[:code]
	        client = Weibo2::Client.from_code(code)
        	uid=client.token.params["uid"]
        	db_user=User.where(:Id=>uid).first
        	unless db_user
                	user=JSON.parse(client.users.show({:uid=>uid}).body)
                	db_user=User.new
                	db_user.Id=uid
                	db_user.Name=user["name"]
                	db_user.AvatarURL=user["profile_image_url"]
                	db_user.Type="weibo"
                        db_user.save
       		end
	else
        	data=request.env['omniauth.auth'].to_hash
        	uid=data["uid"]
        	db_user=User.where(:Id=>uid).first
        	unless db_user
        	        db_user=User.new
        	        db_user.Id=uid
               		db_user.Name=data["info"]["name"]
                	db_user.Email=data["info"]["email"]
                	db_user.AvatarURL=data["info"]["image"]
                        db_user.Type="google"
                	db_user.save
        	end
	end
        session[:current_user]=db_user
        return db_user.Id
end

get '/api/block/:id' do
	id=params[:id][1..-1]
	block=Block.where(:Id=>id).first
	block.to_json
end

get '/api/article/:id' do
	unless session[:current_user]
		nologin_user=User.new
		session[:current_user]=nologin_user
	end
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
	if session[:current_user].Id==nil
		session[:current_user]=nil
	end
	article.to_json
end

post '/api/append_block/:id' do
	unless session[:current_user]
		return "please login"
	end
	id=params[:id][1..-1]
	text=params[:text]
	block=Block.where(:Id=>id).to_a[0]
	user_id=session[:current_user].Id
	is_public=block.Public
	if block.ParentId
		pid=block.ParentId
		pblock=Block.where(:Id=>pid).to_a[0]
		a_uid=pblock.AuthorId
		subject=pblock.Subject
		next_block=Block.where(:ParentId=>pid,:Order.gt=>block.Order).sort(Order: 1).to_a[0]
		if next_block
			order=(block.Order+next_block.Order)/2.0
		else
			order=block.Order+1.0
		end
		pblock.Updated_on=DateTime.now
		pblock.save
		is_public=pblock.Public
	else
		pid=block.Id
		subject=block.Subject
		a_uid=block.AuthorId
		first_block=Block.where(:ParentId=>pid).sort(Order: 1).to_a[0]
		if first_block
			order=first_block.Order/2.0
		else
			order=1.0
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

post '/api/comment_block/:id' do
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
	block.RightBlockCount=0 unless block.RightBlockCount
	block.RightBlockCount=block.RightBlockCount+1
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

post '/api/delete_block' do
	re_count_id_list=[]
	unless session[:current_user]
		return "please login"
	end
	id=params[:id][1..-1]
	block=Block.where(:Id=>id).first
	unless block.ParentId
		block.delete
		BlockLink.where(:LeftId=>id).delete
		BlockLink.where(:RightId=>id).all.each do |bl|
			re_count_id_list << bl.LeftId
		end
		BlockLink.where(:RightId=>id).delete
		Block.where(:ParentId=>id).all.each do |b|
			BlockLink.where(:LeftId=>b.Id).delete
			BlockLink.where(:RightId=>b.Id).all.each do |bl|
				re_count_id_list << bl.LeftId
			end
			BlockLink.where(:RightId=>b.Id).delete
		end
		Block.where(:ParentId=>id).delete
		re_count_right_block(re_count_id_list)
		return "OK_ALL"
	else
		parent_block=Block.where(:Id=>block.ParentId).first
		parent_block.Updated_on=DateTime.now
		parent_block.save
		block.delete
		BlockLink.where(:LeftId=>id).delete
		BlockLink.where(:RightId=>id).all.each do |bl|
			re_count_id_list << bl.LeftId
		end
		BlockLink.where(:RightId=>id).delete
		re_count_right_block(re_count_id_list)
		return "OK"
	end
end

post '/api/edit_block/:id' do
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

post '/api/add_left_block/:id' do
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
	left_block=Block.where(:Id=>left_id).first
	left_block.RightBlockCount=0 unless left_block.RightBlockCount
	left_block.RightBlockCount=left_block.RightBlockCount+1
	left_block.save
	return "OK"
end

post '/api/add_exist_block/:id' do
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

post '/api/clone_block/:id' do
	unless session[:current_user]
		return "please login"
	end
	id=params[:id][1..-1]
	block=Block.where(:Id=>id).first
	block.RightBlockCount=0 unless block.RightBlockCount
	block.RightBlockCount=block.RightBlockCount+1
	block.save
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

post '/api/delete_link' do
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
	left_block=Block.where(:Id=>left_id).first	
	left_block.RightBlockCount=left_block.RightBlockCount-1
	left_block.save
	return "OK"
end

get '/api/cache/:id' do	
	@current_user=session[:current_user]
	if @current_user
		content=CachedContent.where(:Id=>params[:id],:AuthorId=>@current_user.Id).first
		if content
			return content.to_json
		end
	end
	return ""
end

post '/api/cache/:id' do
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

delete '/api/cache/:id' do
	@current_user=session[:current_user]
	if @current_user
		CachedContent.where(:Id=>params[:id],:AuthorId=>@current_user.Id).delete
	end
end

post '/api/follow_user/:id' do
	to_user_id=params[:id]
	from_user_id=params[:from_user_id]
	w=Watch.new
	w.UserId=from_user_id
	w.WatchedId=to_user_id
	w.WatchType='user'
	w.save
	"OK"
end

post '/api/unfollow_user/:id' do
	to_user_id=params[:id]
	from_user_id=params[:from_user_id]
	Watch.where(:UserId=>from_user_id,:WatchedId=>to_user_id,:WatchType=>'user').delete
	"OK"
end

get '/api/articles' do
        Block.where(:ParentId=>nil,:Type=>"topic",:Public=>1).sort(Updated_on: -1).to_a.to_json
end
