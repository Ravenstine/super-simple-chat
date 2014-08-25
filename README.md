Super Simple Chat
==

This is a simple chat to demonstrate server-sent events in Rails 4 using ActionController::Live.
It requires no database or model.  However, you will need:

* Rails >= 4.0.0
* Ruby >= 1.9
* Puma

Sever Sent Events
--------

The Live feature in ActionController allows the app to send events from the server to the client using the standard HTTP protocol.  This means the server can trigger something to happen in JavaScript without the need for WebSockets or other protocols.

This little chat app should be helpful for anyone who wants to understand how server-sent events can be accomplished in Rails.  It uses a default stack(aside from Puma), and extra features to the chat can be added very easily once you understand what's going on.

Concurrency is achieved using the threading behavior of Puma.  This is different from an event loop / reactor pattern and has its own set of advantages and drawbacks; for every user, Puma spawns a new thread in Ruby.

Most implementations of ActionController::Live rely on either a simple times loop or the pub/sub functionality of Redis.  I decided to use ActiveSupport::Notifications for pub/sub because it is built in to Rails and gets the job done quite nicely.  It is also thread-safe.  Redis does a very nice job and has the advantage of running separately from Rails.

Because Rails is not a web server, it cannot alone determine in a native way if a user has disconnected.  To get around this, the chat application provides a "heartbeat" event that gets sent to every user every 10 seconds.  If a user has disconnected, Rails will attempt to send a response twice before raising an IOError at which point we know to end the stream(closing the thread).  Frameworks that also function as web servers(ie. Goliath) can detect a closed connection and do not need the kind of heartbeat we are using.

Installation
-----
Just:

```bundle install```

then:

```rails s```

Or if you want to run the server with a custom thread limit:

```puma -t 8:32```


Why won't my connections die when I deploy my app to Heroku?
------

In this case, the routing proxy that Heroku uses prevents the server from knowing if a client has disconnected.  This means that response.stream.closed? will always return false.  The routing in Heroku cannot be configured by the developer.
However, enabling WebSockets seems to solve this problem.  You can do this by going to the root directory of your project and running the following:

```heroku labs:enable websockets```

This will configure the routing to support WebSockets in a way that happens to also support SSEs.  Now response.stream.closed? will return true when the stream is dead.  Let's hope that Heroku keeps this feature!

License
-------

This app is public domain.  Have at it!
