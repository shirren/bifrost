require 'spec_helper'
require 'bifrost/topic'
require 'bifrost/subscriber'

describe Bifrost::Topic do
  subject(:topic) { Bifrost::Topic.new('topic_name') }

  it { is_expected.to respond_to(:name) }
  it { is_expected.to respond_to(:exists?) }
  it { is_expected.to respond_to(:save) }
  it { is_expected.to respond_to(:delete) }
  it { is_expected.to respond_to(:add_subscriber) }
  it { is_expected.to respond_to(:remove_subscriber) }

  it 'should not support blank topic names' do
    invalid_topic = Bifrost::Topic.new(nil)
    expect { invalid_topic.save }.to raise_error(TypeError)
  end

  context 'for an undefined topic' do
    it 'should return false for defined?' do
      expect(topic.exists?).to be_falsey
    end

    it 'should persist the topic' do
      new_topic = Bifrost::Topic.new('new_topic_name')
      expect(new_topic.save).to be_truthy
      expect(new_topic.delete).to be_truthy
    end

    it 'should return false for delete' do
      expect(topic.delete).to be_falsey
    end

    it 'should not be able to add a new subscriber' do
      subscriber = Bifrost::Subscriber.new('new_subscriber')
      expect(topic.add_subscriber(subscriber)).to be_falsey
    end

    it 'should not be able to remove a subscriber' do
      subscriber = Bifrost::Subscriber.new('new_subscriber')
      expect(topic.remove_subscriber(subscriber)).to be_falsey
    end
  end

  context 'for a defined topic' do
    let(:new_topic) { Bifrost::Topic.new('test_donotdelete') }

    before(:all) do
      tp = Bifrost::Topic.new('test_donotdelete')
      tp.save unless tp.exists?
    end

    after(:all) do
      tp = Bifrost::Topic.new('test_donotdelete')
      tp.delete if tp.exists?
    end

    it 'should return true for defined?' do
      expect(new_topic.exists?).to be_truthy
    end

    it 'should return false for save' do
      expect(new_topic.save).to be_falsey
    end

    it 'should be able to add and remove a new subscriber' do
      subscriber = Bifrost::Subscriber.new('new_subscriber')
      expect(new_topic.add_subscriber(subscriber)).to be_truthy
      expect(new_topic.remove_subscriber(subscriber)).to be_truthy
    end

    it 'should not be able to remove a non existent subscriber' do
      subscriber = Bifrost::Subscriber.new('non_existent_subscriber')
      expect(new_topic.remove_subscriber(subscriber)).to be_falsey
    end

    it 'should not be able to add a duplicate subscriber' do
      subscriber = Bifrost::Subscriber.new('another_new_subscriber')
      expect(new_topic.add_subscriber(subscriber)).to be_truthy
      expect { new_topic.add_subscriber(subscriber) }.to raise_error(Bifrost::Exceptions::DuplicateSubscriberError)
    end
  end

  it 'should not accept names with spaces in them' do
    invalid_topic_name = Bifrost::Topic.new('topic name')
    expect { invalid_topic_name.save }.to raise_error(URI::InvalidURIError)
  end
end
