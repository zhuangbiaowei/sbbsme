require './lib/observer'
Mongoid.configure.load!("./config/mongoid.yml")
Mongoid.observers = BlockObserver,BlockLinkObserver
Mongoid.instantiate_observers
