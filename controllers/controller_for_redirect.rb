get '/' do
	redirect "/home"
end


get '/weibo/login' do
	Weibo2::Config.redirect_uri = "http://sbbs.me/weibo/callback"
	client = Weibo2::Client.new
	redirect client.auth_code.authorize_url
end

get '/weibo/callback' do
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
		db_user.Type='weibo'
		db_user.save
	end
	session[:current_user]=db_user
	redirect "/home"
end

get '/auth/:provider/callback' do
	data=request.env['omniauth.auth'].to_hash
	uid=data["uid"]
	db_user=User.where(:Id=>uid).first
	unless db_user
		db_user=User.new
		db_user.Id=uid
		db_user.Name=data["info"]["name"]
		db_user.Email=data["info"]["email"]
		db_user.AvatarURL=data["info"]["image"]
		db_user.Type='google'
		db_user.save
	end
	session[:current_user]=db_user
	redirect "/home"
end

get '/auth/failure' do
	content_type 'text/plain'
	request.env['omniauth.auth'].to_hash.inspect rescue "No Data"
end

get '/logout' do
	session[:current_user]=nil
	redirect '/home'
end

get '/last' do
	block=Block.where(:Type=>'topic',:Public=>1).last
	if block
		redirect '/post/'+block.Id
	else
		redirect '/home'
	end
end

post '/post' do
	if session[:current_user]
		block=Block.new
		block.Id=block.id
		block.Subject=params[:subject]
		block.Format=params[:format]
		block.Body=params[:txtBody]
		block.Created_on=DateTime.now
		block.AuthorId=session[:current_user].Id
		block.Type="topic"
		block.Public=params[:public].to_s.to_i
		block.save
		update_tags(block.id,params[:tags])
		CachedContent.where(:Id=>'new',:AuthorId=>session[:current_user].Id).delete
		redirect "/post/"+block.Id
	else
		redirect "/home"
	end
end

post '/edit_post/:id' do
	if session[:current_user]
		id=params[:id]
		block=Block.where(:Id=>id).first
		block.Subject=params[:subject]
		block.Updated_on=DateTime.now
		block.Public=params[:public]
		block.Format=params[:format]
		block.save
		update_tags(id,params[:tags])
		redirect "/post/"+block.Id
	else
		redirect "/home"
	end	
end

def update_tags(id,tags)
	BlockTag.where(:BlockId=>id).delete
	tags.split(",").each do |tag_name|
		tag=Tag.where(:Name=>tag_name).first
		unless tag
			tag=Tag.new
			tag.Name=tag_name
			tag.Id=tag._id
			tag.save
		end
		bt=BlockTag.new
		bt.BlockId=id
		bt.TagId=tag.Id
		bt.save
	end	
end
