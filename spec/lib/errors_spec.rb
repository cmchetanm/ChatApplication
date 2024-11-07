require 'rails_helper'

RSpec.describe Errors do
  let(:errors) { Errors.new }

  describe '#add' do
    it 'adds a new error message for a key' do
      errors.add(:name, 'is required')
      expect(errors[:name]).to eq(['is required'])
    end

    it 'appends error message to existing key' do
      errors.add(:name, 'is required')
      errors.add(:name, 'is invalid')
      expect(errors[:name]).to eq(['is required', 'is invalid'])
    end

    it 'prevents duplicate error messages' do
      errors.add(:name, 'is required')
      errors.add(:name, 'is required')
      expect(errors[:name]).to eq(['is required'])
    end
  end

  describe '#add_multiple_errors' do
    it 'adds multiple errors from hash' do
      error_hash = {
        name: ['is required', 'is invalid'],
        email: ['is invalid']
      }
      errors.add_multiple_errors(error_hash)
      expect(errors[:name]).to eq(['is required', 'is invalid'])
      expect(errors[:email]).to eq(['is invalid'])
    end

    it 'handles empty error hash' do
      errors.add_multiple_errors({})
      expect(errors).to be_empty
    end

    it 'maintains uniqueness when adding multiple errors' do
      error_hash = {
        name: ['is required', 'is required', 'is invalid']
      }
      errors.add_multiple_errors(error_hash)
      expect(errors[:name]).to eq(['is required', 'is invalid'])
    end
  end

  describe '#each' do
    it 'yields each error message with its field' do
      errors.add(:name, 'is required')
      errors.add(:name, 'is invalid')
      errors.add(:email, 'is invalid')

      collected_errors = []
      errors.each do |field, message|
        collected_errors << [field, message]
      end

      expect(collected_errors).to eq([
        [:name, 'is required'],
        [:name, 'is invalid'],
        [:email, 'is invalid']
      ])
    end

    it 'handles empty errors' do
      collected_errors = []
      errors.each do |field, message|
        collected_errors << [field, message]
      end
      expect(collected_errors).to be_empty
    end
  end
end
