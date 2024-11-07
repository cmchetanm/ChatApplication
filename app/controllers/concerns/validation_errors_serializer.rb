# frozen_string_literal: true

class ValidationErrorsSerializer
  attr_reader :record

  def initialize(record)
    @record = record
  end

  def serialize
    record.errors.messages.flat_map do |field, messages|
      messages.map do |detail|
        ValidationErrorSerializer.new(record, field, detail).serialize
      end
    end
  end
end
