# frozen_string_literal: true

require 'http'

RSpec.describe Koltira::DependencyContainer do
  before do
    ip_address_service = Class.new do
      def initialize
        @client = HTTP.persistent('https://jsonip.com')
      end

      def call
        @client.get('/').parse(:json)
      end
    end

    stub_const('IpAddressService', ip_address_service)
  end

  it 'has a version number' do
    expect(Koltira::DependencyContainer::VERSION).not_to be nil
  end

  it 'should create a module, declare a dependency and call that dependency' do
    foo_module = Module.new do
      extend Koltira::DependencyContainer

      # with a symbol
      dependency :ip_address do
        IpAddressService.new
      end

      # with a string
      dependency 'service.ip_address' do
        IpAddressService.new
      end
    end

    output1 = foo_module.di('service.ip_address').call
    output2 = foo_module.di(:ip_address).call
    expect(output1.key?('ip')).to be(true)
    expect(output2.key?('ip')).to be(true)
  end
end
