require 'rails_helper'

class TestService < ApplicationService
  def call
    true
  end
end

class FailingService < ApplicationService
  def call
    errors.add(:base, "Something went wrong")
    false
  end
end

RSpec.describe ApplicationService do
  describe '.call' do
    it 'instantiates and calls the service' do
      result = TestService.call
      expect(result).to be_success
      expect(result.result).to eq(true)
    end
  end

  describe '#success?' do
    it 'returns true when there are no errors' do
      service = TestService.call
      expect(service.success?).to be true
    end

    it 'returns false when there are errors' do
      service = FailingService.call
      expect(service.success?).to be false
    end
  end

  describe '#failure?' do
    it 'returns true when there are errors' do
      service = FailingService.call
      expect(service.failure?).to be true
    end

    it 'returns false when there are no errors' do
      service = TestService.call
      expect(service.failure?).to be false
    end
  end

  describe '#errors' do
    it 'initializes a new Errors object' do
      service = TestService.new
    end

    it 'maintains the same errors object between calls' do
      service = TestService.new
      first_call = service.errors
      second_call = service.errors
      expect(first_call).to equal(second_call)
    end
  end

  describe '#call' do
    it 'raises NotImplementedError when not implemented in subclass' do
      service = ApplicationService.new
      expect { service.call }.to raise_error(NotImplementedError)
    end
  end
end
