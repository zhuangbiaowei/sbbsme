class User
	include Mongoid::Document
	field :Id, type: String
	field :Name, type: String
	field :Email, type: String
	field :AvatarURL, type: String
	field :Type, type: String
	field :Created_on, type: DateTime, default: Time.now
	field :Updated_on, type: DateTime, default: Time.now
end

class Image
	include Mongoid::Document
	field :Id, type: String
	field :FileName, type: String
	field :URL, type: String
	field :AuthorId, type: String
	field :Upload_on, type: DateTime, default: Time.now
end

class Block
	include Mongoid::Document
	field :Id, type: String
	field :ParentId, type: String
	field :Subject, type: String
	field :Body, type: String
	field :AuthorId, type: String
	field :Order, type: Float, default: 0.0
	field :Status, type: String
	field :Type, type: String
	field :Public, type: Integer
	field :RightBlockCount, type: Integer, default: 0
	field :Created_on, type: DateTime, default: Time.now
	field :Updated_on, type: DateTime, default: Time.now
	field :Format, type: String, default: "Markdown"
end

class BlockBackup
	include Mongoid::Document
	field :Id, type: Integer
	field :BlockId, type: Integer
	field :Subject, type: String
	field :Body, type: String
	field :AuthorId, type: String
	field :Version, type: Integer
	field :Created_on, type: DateTime, default: Time.now
end

class BlockLink
	include Mongoid::Document
	field :LeftId, type: String
	field :LeftSite, type: String
	field :RightId, type: String
	field :RightSite, type: String
	field :Opinion, type: String
	field :MarkPos, type: Integer
	field :Type, type: String
	field :Order, type: Float
	field :Created_on, type: DateTime, default: Time.now
	field :Updated_on, type: DateTime, default: Time.now
end

class BlockTag
	include Mongoid::Document
	field :BlockId, type: String
	field :TagId, type: String
end

class Tag
	include Mongoid::Document
	field :Id, type: String
	field :Name, type: String
	field :Description, type: String
	field :BlockCount, type: Integer
end

class Watch
	include Mongoid::Document
	field :Id, type: String
	field :WatchedId, type: String
	field :WatchType, type: String
	field :UserId, type: String
	field :Created_on, type: DateTime, default: Time.now
end

class CachedContent
	include Mongoid::Document
	field :Id, type: String
	field :AuthorId, type: String
	field :Subject, type: String
	field :Body, type: String
end

class PrivateMessage
	include Mongoid::Document
	field :Id, type: Integer
	field :FromUserId, type: String
	field :FromUserName, type: String
	field :ToUserId, type: String
	field :ToUserName, type: String
	field :Format, type: String
	field :Body, type: String
	field :Created_on, type: DateTime, default: Time.now
end
