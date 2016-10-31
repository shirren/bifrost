require 'spec_helper'
require 'bifrost'

describe Bifrost::Supervisor do
  let(:proc)        { Proc.new { |m| puts "Received: message #{m}" }}
  let(:worker)      { Bifrost::Worker.new('topic', 'subscriber', proc) }
  let(:supervisors) { Bifrost::Supervisor.new }

  it 'should contain an empty worker collection on creation' do
    expect(supervisors.workers).to eq([])
  end

  it 'should be able to supervise a single worker' do
    supervisors.add(worker)
    expect(supervisors.workers).to eq([worker])
    supervisors.run
  end
end
