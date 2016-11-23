require 'spec_helper'
require 'bifrost'

describe Bifrost::Topic do
  subject(:topic) { Bifrost::Topic.new('topic_name') }

  it { is_expected.to respond_to(:name) }
  it { is_expected.to respond_to(:save) }
  it { is_expected.to respond_to(:delete) }
  it { is_expected.to respond_to(:add_subscriber) }
  it { is_expected.to respond_to(:remove_subscriber) }

  it 'should not support blank topic names' do
    invalid_topic = Bifrost::Topic.new(nil)
    expect { invalid_topic.save }.to raise_error(TypeError)
  end

  it 'should have a friendly name' do
    expect(topic.to_s).to eq('topic_name')
  end

  it 'should not accept names with spaces in them' do
    invalid_topic = Bifrost::Topic.new('topic name')
    expect { invalid_topic.save }.to raise_error(URI::InvalidURIError)
  end

  describe 'equality' do
    it 'should return true for the same object' do
      expect(topic).to eq(topic)
    end

    it 'should return true for topics with the same name' do
      same_topic = Bifrost::Topic.new('topic_name')
      expect(same_topic).to eq(topic)
    end

    it 'should return false for topics with disimilar names' do
      different_topic = Bifrost::Topic.new('different_topic_name')
      expect(different_topic).not_to eq(topic)
    end
  end

  context 'for an undefined topic' do
    describe 'save' do
      it 'should persist the topic and return a binary value' do
        new_topic = Bifrost::Topic.new('new_topic_name')
        expect(new_topic.save).to be_truthy
        expect(new_topic.delete).to be_truthy
      end
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

    before(:each) do
      new_topic.save
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
      expect(new_topic.add_subscriber(subscriber)).to be_falsey
    end

    context 'with no subscribers' do
      it 'should return no subscribers' do
        expect(new_topic.subscribers).to be_empty
      end
    end

    context 'with subscribers' do
      before(:each) do
        subscriber_a = Bifrost::Subscriber.new('new_subscriber_a')
        subscriber_b = Bifrost::Subscriber.new('new_subscriber_b')
        new_topic.add_subscriber(subscriber_a)
        new_topic.add_subscriber(subscriber_b)
      end

      it 'should return a list of it\'s subscribers' do
        expect(new_topic.subscribers.size).to eq(2)
      end
    end
  end
end
