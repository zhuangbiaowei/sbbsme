# encoding: utf-8

class BlockObserver < Mongoid::Observer
	def after_create(doc)
	end
end

class BlockLinkObserver < Mongoid::Observer
end

class WatchObserver < Mongoid::Observer
	def after_create(doc)
		if doc.WatchType=="user"
			user=User.where(:Id=>doc.UserId).first
			send_message(doc.WatchedId,"<a href='/user/#{user.Id}'>#{user.Name}</a> now follow you.")
		end
	end
end