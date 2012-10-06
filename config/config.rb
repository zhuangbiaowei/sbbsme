require './lib/observer'
Mongoid.configure.load!("./config/mongoid.yml")
Mongoid.observers = BlockObserver,BlockLinkObserver,WatchObserver
Mongoid.instantiate_observers
