require 'rails_helper'

RSpec.describe ApplicationMethods, type: :controller do
  controller(ApplicationController) do
    include ApplicationMethods

    skip_before_action :authenticate_request
    
    def test_not_found
      User.find(0)
    end

    def test_parameter_missing
      params.require(:missing_param)
    end

    def test_argument_error
      raise ArgumentError, 'Invalid argument'
    end

    def test_standard_error
      raise StandardError, 'Something went wrong'
    end

    def test_record_invalid
      user = User.new
      user.errors.add(:base, "Custom validation error")
      raise ActiveRecord::RecordInvalid.new(user)
    end

    def test_action
      render_success_response({ data: 'test' }, 'Success')
    end
  end

  before do
    routes.draw do
      get 'test_action' => 'anonymous#test_action'
      get 'test_not_found' => 'anonymous#test_not_found'
      get 'test_parameter_missing' => 'anonymous#test_parameter_missing'
      get 'test_argument_error' => 'anonymous#test_argument_error'
      get 'test_standard_error' => 'anonymous#test_standard_error'
      get 'test_record_invalid' => 'anonymous#test_record_invalid'
    end
  end

  describe '#handle_exceptions' do
    it 'handles ActiveRecord::RecordNotFound with 404 status' do
      get :test_not_found
      expect(response).to have_http_status(404)
      expect(JSON.parse(response.body)['success']).to be false
    end

    it 'handles ActionController::ParameterMissing with 422 status' do
      get :test_parameter_missing
      expect(response).to have_http_status(422)
      expect(JSON.parse(response.body)['success']).to be false
    end

    it 'handles ArgumentError with 400 status' do
      get :test_argument_error
      expect(response).to have_http_status(400)
      expect(JSON.parse(response.body)['success']).to be false
    end

    it 'handles StandardError with 500 status' do
      get :test_standard_error
      expect(response).to have_http_status(500)
      expect(JSON.parse(response.body)['success']).to be false
    end

    it 'handles ActiveRecord::RecordInvalid with 422 status' do
      get :test_record_invalid
      expect(response).to have_http_status(422)
      expect(JSON.parse(response.body)['success']).to be false
      expect(JSON.parse(response.body)).to have_key('errors')
    end
  end

  describe '#render_success_response' do
    it 'renders success response with correct format' do
      get :test_action
      expect(response).to have_http_status(200)
      
      json_response = JSON.parse(response.body)
      expect(json_response['success']).to be true
      expect(json_response['message']).to eq('Success')
      expect(json_response['data']).to eq({ 'data' => 'test' })
    end
  end

  describe '#render_unauthorized_response' do
    controller do
      def test_unauthorized
        render_unauthorized_response(token: ['Token has expired'])
      end
    end

    before do
      routes.draw do
        get 'test_unauthorized' => 'anonymous#test_unauthorized'
      end
    end

    it 'renders unauthorized response with expired token' do
      get :test_unauthorized
      expect(response).to have_http_status(401)
      
      json_response = JSON.parse(response.body)
      expect(json_response['success']).to be false
      expect(json_response['message']).to eq('You are not authorized.')
      expect(json_response['errors'].last['token_expired']).to be true
    end
  end

  describe '#render_unprocessable_entity' do
    controller do
      def test_unprocessable
        render_unprocessable_entity('Invalid data')
      end
    end

    before do
      routes.draw do
        get 'test_unprocessable' => 'anonymous#test_unprocessable'
      end
    end

    it 'renders unprocessable entity response' do
      get :test_unprocessable
      expect(response).to have_http_status(422)
      
      json_response = JSON.parse(response.body)
      expect(json_response['success']).to be false
      expect(json_response['errors']).to eq(['Invalid data'])
    end
  end
end
