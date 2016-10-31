# Bifrost

Bifrost is a component which abstracts access to the Azure messaging bus. This is a lower level library which
can be used to commuicate with Azure via the Azure SDK.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'bifrost'
```

And then execute:

    $ bundle

## Usage

This component consists of 4 primary entities; Topic, Subscriber, Message and Listener.

Message's are what we deliver across various applications via an asynchronous pub/sub architecture. Messages are
posted to Topics. Topics are a collection of unique names which exist in a given Azure namespace. Each instance
of the Bifrost can only operate in a single Azure namespace. Topic names support alpha numeric characters only.

The architecture of this component is based on a fan out pub/sub model, i.e. a topic can have 1 or more subscribers,
each subscriber registers their interest in receiving messages posted to the topic. For more information on service
bus and how it works please refer to this [article](https://azure.microsoft.com/en-us/documentation/articles/service-bus-fundamentals-hybrid-solutions/#service-bus-fundamentals).

### Configuration

To begin using this gem we need to start by setting some environment variables. The gem in development and
test environments supports .env files (i.e. .env.test and .env.development etc). The environment variables that
require to be set prior to using the gem are; NAMESPACE, KEY_NAME and KEY_SECRET. The values for these variables
can be obtained from your Azure management portal. For more information on how to obtain these values for your
service bus please refer to this [article](https://azure.microsoft.com/en-us/documentation/articles/service-bus-authentication-and-authorization/).

### Examples

To define a topic to which messages can be delivered;

```ruby
topic = Bifrost::Topic.new('topic_name')
topic.save
```

The `save` method returns a `true` or `false` to indicate if the topic was successfully saved. A topic may not save
if it already exists.

To add a subscriber to a particular topic;

```ruby
topic = Bifrost::Topic.new('topic_name')
topic.save
subscriber = Bifrost::Subscriber.new('new_subscriber')
topic.add_subscriber(subscriber)
```

Each topic can only have a unique list of subscribers, a subscriber cannot be added to a topic more than once. When a subscriber is added to
a topic this function will return a true or false indicating success of the add.

To post a message to a topic;

```ruby
topic = Bifrost::Topic.new('topic_name')
message = Bifrost::Message.new(content: 'some data')
message.post_to(topic)
```

This function returns a `true` or `false` indicating the success of the message delivery. This method is synchronous. Each message has an
identifier which gets sets upon successful delivery only.

A message can also be optionally published with a subject;

```ruby
topic = Bifrost::Topic.new('topic_name')
message = Bifrost::Message.new(content: 'some data', 'message subject')
message.post_to(topic)
```

Subscribers in the Bifrost are [actors](http://http://doc.akka.io/docs/akka/2.4/general/actors.html), these actors run in
their own threads. At present the Bifrost does not support thread pools, this is something we are investigating and are
hoping to add at some point. In the Bifrost each actor is referred to as a `worker`. A worker is designed to receive
messages published to a particular topic with a specific subscriber in mind (refer to the fan-out comment earlier).

Workers are added to the Bifrost via the manager. The manager is what activates the workers in the Bifrost environment.
You can use multiple managers if you like at any given point in time to orchestrate the workers. These managers and workers
are only allowed to work in a single namespace at a time.

To setup a single worker to receive messages sent to a particular topic and subscriber;

```ruby
manager = Bifrost::Manager.new
manager.add('topic_name', 'subscriber_name', proc { |m| puts "Received: message #{m}" })
manager.run
end
```

To setup multiple workers to receive messages;

```ruby
manager = Bifrost::Manager.new
manager.add('topic_name', 'subscriber_name', proc { |m| puts "Received: message #{m}" })
manager.add('another_topic_name', 'another_subscriber_name', proc { |m| puts "Received: message #{m}" })
manager.run
end
```

Workers in the Bifrost are self healing, when an actor dies the manager receives a message alerting the manager
to the failure, the worker then restarts after the failure.

**We hope to introduce custom lambda functions in the future to support custom actions when a worker dies**

#Is it any good?

We are currently [dogfooding](https://en.wikipedia.org/wiki/Eating_your_own_dog_food) this product in our production
environment. We will no doubt find issues and rectify this over time.

#Contributing

We'd love to have you involved. Please read our [contributing guide]() for information on how to get stuck in.

Contributors

This project is managed by the Filmpond team.

These individuals have come up with the ideas and written the code that made this possible:

1. Shirren Premaratne
2. Leslie Fung

#Licence

This program is free software: you can redistribute it and/or modify it under the terms of the MIT License.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the MIT License for more details.

The MIT License (MIT)

Copyright (C) 2016 Filmpond Pty Ltd

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.