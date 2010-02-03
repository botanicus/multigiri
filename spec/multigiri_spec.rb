# encoding: utf-8

require_relative "spec_helper"

describe Multigiri do
  it "should have VERSION constant" do
    Multigiri::VERSION.should be_kind_of(String)
    Multigiri::VERSION.should match(/^\d+\.\d+\.\d+$/)
  end
end
