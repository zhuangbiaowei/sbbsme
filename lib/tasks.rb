#all tasks
require 'gearman'

def get_taskset
	client = Gearman::Client.new('localhost')
	taskset = Gearman::TaskSet.new(client)
end

def create_new_post_task(doc)
	task = Gearman::Task.new('create_new_post', Marshal.dump(doc))
	get_taskset.add_task(task)
end

def append_to_post_task(doc)
	task = Gearman::Task.new('append_to_post_task', Marshal.dump(doc))
	get_taskset.add_task(task)
	
end

def create_new_link_task(link)
	task = Gearman::Task.new('create_new_link_task', Marshal.dump(link))
	get_taskset.add_task(task)	
end