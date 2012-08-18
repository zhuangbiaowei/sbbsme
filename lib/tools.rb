require 'sinatra'
require 'mongoid'
require './config/config'
require './models/models'

def add_block(id,subject,body,parent_id=nil)
	b=Block.new
	b.ParentId=parent_id
        b.Id=id
        b.Subject=subject
        b.Body=body
        b.save
end

def add_block_link(left_id,right_id,type)
	bl=BlockLink.new
	bl.LeftId=left_id
	bl.RightId=right_id
	bl.Type=type
	bl.save
end
