require 'redis'

get '/home' do
	@tags=Tag.all.sort(BlockCount: -1)
	@article_list=Block.where(:ParentId=>nil,:Type=>"topic",:Public=>1).sort(Updated_on: -1).to_a
	@current_user=session[:current_user]
	@msg_count = get_msg_count(@current_user)
	@private_msg_count = get_private_msg_count(@current_user)
	haml :home
end

get '/tags/:id' do
	@tags=Tag.all.sort(BlockCount: -1)
	@current_user=session[:current_user]
	@msg_count = get_msg_count(@current_user)
	@private_msg_count = get_private_msg_count(@current_user)
	id=params[:id]
	block_ids=[]
	BlockTag.where(:TagId=>id).all.each do |bt|
		block_ids<<bt.BlockId
	end
	@article_list=Block.in(:Id=>block_ids).where(:Public=>1).all
	haml :home
end

get '/new' do
	@current_user=session[:current_user]
	@tags=Tag.all.sort(BlockCount: -1)
	@msg_count = get_msg_count(@current_user)
	@private_msg_count = get_private_msg_count(@current_user)
	haml :new
end

get '/post/:id' do
	@current_user=session[:current_user]
	@msg_count = get_msg_count(@current_user)
	@private_msg_count = get_private_msg_count(@current_user)
	if @current_user
		@tags=Tag.all.sort(BlockCount: -1)
		@id=params[:id]
		block=Block.where(:Id=>@id).first
		if block
			if @current_user
				@is_author=(@current_user.Id.to_s==block.AuthorId.to_s||@current_user.Type==1)
			else
				@is_author=false
			end
			haml :post
		else
			redirect '/home'
		end
	else
		redirect '/view_article/'+params[:id]
	end
end

get '/view_article/:id' do
	@current_user=session[:current_user]
	@msg_count = get_msg_count(@current_user)
	@private_msg_count = get_private_msg_count(@current_user)
	@tags=Tag.all.sort(BlockCount: -1)
	@id=params[:id]	
	block=Block.where(:Id=>@id).first
	if block
		if block.Public==1
        	        @title=block.Subject
                	@html="<div class=\"component "+block.Format+"\">"+block.Body+"</div>\n"
                	Block.where(:ParentId=>@id).all.sort(Order: 1).each do |block|
                	        @html=@html+"<div class=\"component "+block.Format+"\">"+block.Body+"</div>\n"
               		end
                	haml :view_article
        	else
        	        redirect '/home'
	        end
	else
		redirect '/home'
	end
end

get '/edit_post/:id' do
	@current_user=session[:current_user]
	@msg_count = get_msg_count(@current_user)
	@private_msg_count = get_private_msg_count(@current_user)
	@tags=Tag.all.sort(BlockCount: -1)
	@id=params[:id]
	@block=Block.where(:Id=>@id).first
	@tag_string=BlockTag.where(:BlockId=>@id).all.to_a.collect{|bt| Tag.where(:Id=>bt.TagId).first.Name}.join(",")
	haml :edit
end

get '/profile' do
	@current_user=session[:current_user]
	@msg_count = get_msg_count(@current_user)
	@private_msg_count = get_private_msg_count(@current_user)
	@tags=Tag.all.sort(BlockCount: -1)
	@topics=Block.where(:AuthorId=>@current_user.Id,:Type=>'topic').all
	@blocks=Block.in(Type:['comment','clone']).where(:AuthorId=>@current_user.Id).all
	haml :profile
end

get '/user/:id' do
	@current_user=session[:current_user]
	@msg_count = get_msg_count(@current_user)
	@private_msg_count = get_private_msg_count(@current_user)
	@tags=Tag.all.sort(BlockCount: -1)
	@user=User.where(:Id=>params[:id]).first
	@topics=Block.where(:AuthorId=>params[:id],:Public=>1,:Type=>'topic').all
	@blocks=Block.in(Type:['comment','clone']).where(:AuthorId=>params[:id],:Public=>1).all
	if @current_user
		if @current_user.Id==@user.Id
			@is_me=true
		else
			if is_followed(@current_user.Id,@user.Id)
				@is_followed=true
			else
				@is_unfollow=true
			end
		end
	end
	haml :user
end

get '/admin_user/:id' do
	@current_user=session[:current_user]
	@msg_count = get_msg_count(@current_user)
	@private_msg_count = get_private_msg_count(@current_user)
	if @current_user
		if @current_user.Type=="admin"
			@tags=Tag.all.sort(BlockCount: -1)
			@user=User.where(:Id=>params[:id]).first
			@topics=Block.where(:AuthorId=>params[:id],:Type=>'topic').all
			@blocks=Block.in(Type:['comment','clone']).where(:AuthorId=>params[:id]).all
			haml :admin_user
		else
			redirect '/home'
		end
	else
		redirect '/home'
	end
end

get '/admin' do
	@current_user=session[:current_user]
	@msg_count = get_msg_count(@current_user)
	@private_msg_count = get_private_msg_count(@current_user)
	if @current_user
		if @current_user.Type=="admin"
			@tags=Tag.all.sort(BlockCount: -1)
			@users=User.all
			@blocks=Block.all
			haml :admin
		else
			redirect '/home'
		end
	else
		redirect '/home'
	end	
end

get '/recent' do
	@current_user=session[:current_user]
	@private_msg_count = get_private_msg_count(@current_user)
	@tags=Tag.all.sort(BlockCount: -1)
	@msgs = []
	if @current_user	
		r=Redis.new
		id=@current_user.Id
		@msgs = r.lrange(id,0,-1).map! {|v| Marshal.load(v)}
		r.ltrim(id,@msgs.length-20,-1) if @msgs.length>20
		r.del("#{id}_count")
		@msg_count = 0
	end
	haml :recent
end

get '/private_msg' do
	@current_user=session[:current_user]
	@msg_count = get_msg_count(@current_user)
	@tags=Tag.all.sort(BlockCount: -1)
	if @current_user
		@inbox,@new_msg=get_private_msg(@current_user)
		haml :private_msg
	else
		redirect '/home'
	end
end

get '/private_msg/:userid' do
	@current_user=session[:current_user]
	@msg_count = get_msg_count(@current_user)
	@tags=Tag.all.sort(BlockCount: -1)
	if @current_user
		@me=@current_user
		@user=User.where(:Id=>params[:userid]).first
		@private_msgs = PrivateMessage.where(:Id.gt=>0)
			.or(:FromUserId=>params[:userid],:ToUserId=>session[:current_user].Id)
			.or(:FromUserId=>session[:current_user].Id,:ToUserId=>params[:userid])
			.sort(Id: -1)
		haml :private_msg_by_user
	else
		redirect '/home'
	end
end
