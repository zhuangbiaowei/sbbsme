#!/usr/bin/env ruby
require 'rubygems'
require 'gearman'
require 'sinatra'
require 'mongoid'
require '../models/models'
Mongoid.configure.load!("../config/mongoid.yml")
require './utils'

worker = Gearman::Worker.new('localhost')
worker.reconnect_sec = 2


worker.add_ability('create_new_post') do |data,job|
	doc = Marshal.load(data)
	if doc.Public==1
		user = User.where(:Id=>doc.AuthorId).first
		watch_user_list = Watch.where(:WatchType=>"user",:WatchedId=>doc.AuthorId).to_a.collect{|w| w.UserId}
		watch_user_list.each do |user_id|
			send_message(user_id,"<a href='/user/#{user.Id}'>#{user.Name}</a> created new post: <a href='/post/#{doc.Id}'>#{doc.Subject}</a>.")
		end
	end
end

worker.add_ability('append_to_post_task') do |data,job|
	doc = Marshal.load(data)
	if doc.Public==1
		user = User.where(:Id=>doc.AuthorId).first
		watch_user_list = Watch.where(:WatchType=>"post",:WatchedId=>doc.ParentId).to_a.collect{|w| w.UserId}
		watch_user_list.each do |user_id|
			send_message(user_id,"<a href='/user/#{user.Id}'>#{user.Name}</a> append to post a new block: <a href='/post/#{doc.ParentId}'>#{doc.Subject}</a>.")
		end
	end
end

worker.add_ability('create_new_link_task') do |data,job|
	link = Marshal.load(data)
	left_block = Block.find(link.LeftId)
	right_block = Block.find(link.RightId)
	left_user = User.where(:Id=>left_block.AuthorId).first
	right_user = User.where(:Id=>right_block.AuthorId).first
	send_message(left_user.Id,"<a href='/user/#{right_user.Id}'>#{right_user.Name}</a> comment to your post: <a href='/post/#{right_block.Id}'>#{right_block.Subject}</a>.")
	watch=Watch.new
	watch.WatchType="post"
	if left_block.ParentId
		watch.WatchedId=left_block.ParentId
	else
		watch.WatchedId=left_block.Id
	end
	watch.UserId=right_user.Id
	watch.save
end

loop do
	worker.work
end