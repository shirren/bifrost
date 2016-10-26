# Bifrost

Bifrost is a component which abstracts access to our messaging bus. This is a lower level library which we use to
commuicate with Azure via the Azure SDK.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'bifrost', source: 'http://B3U5fzTniCxwgn4e19Cj@gem.fury.io/shirren/'
```

And then execute:

    $ bundle

## Usage

The component consists of 3 primary entities; Topic, Subscriber and Message. Message's are what we deliver
across our various application layers. Messages are posted to Topics. The architecture of this component is
based on the fan out pub/sub model. Subscribers register their interest in receiving messages posted to a topic.

To give a concrete example `New-Pond` is an example of a topic. We can setup two subscribers to this topic. One
subscriber can be Baldr which is interested in registering new ponds, the other can be Ronan which would also be
interested in receiving messages posted to the `New-Pond` topic.