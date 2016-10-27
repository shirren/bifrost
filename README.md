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

The architecture of this component is based on a fan out pub/sub model. A topic can have 1 or more subscribers, each
subscriber registers their interest in receiving messages posted to a topic.

To give a concrete example `?` is an example of a topic. We can setup two subscribers to this topic. One
subscriber can be Baldr which is interested in registering new ponds, the other can be Ronan which would also be
interested in receiving messages posted to the `?` topic.