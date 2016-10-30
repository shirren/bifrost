require 'spec_helper'
require 'bifrost'

describe Bifrost::Supervisor do
  it 'should contain an empty listener collection on creation' do
    supervisors = Bifrost::Supervisor.new
    expect( supervisors.workers ).to eq( [] )
  end
end
