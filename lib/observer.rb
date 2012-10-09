class BlockObserver < Mongoid::Observer
	def after_create(doc)
		if doc.ParentId==nil
			create_new_post_task(doc)
		else
			append_to_post_task(doc)
		end
	end
end

class BlockLinkObserver < Mongoid::Observer
	def after_create(link)
		create_new_link_task(link)
	end
end

class WatchObserver < Mongoid::Observer
	def after_create(doc)
		if doc.WatchType=="user"
			user=User.where(:Id=>doc.UserId).first
			send_message(doc.WatchedId,"<a href='/user/#{user.Id}'>#{user.Name}</a> now follow you.")
		end
	end
end