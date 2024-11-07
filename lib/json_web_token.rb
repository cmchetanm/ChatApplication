require 'jwt'

module JsonWebToken
    extend ActiveSupport::Concern
    SECRET_KEY = Rails.application.secret_key_base

    def self.encode(payload, exp = 24.hours.from_now)
        payload[:exp] = exp.to_i
        JWT.encode(payload, SECRET_KEY)
    end

    def self.decode(token)
        return nil if BlacklistedToken.exists?(token: token)
        decoded = JWT.decode(token, SECRET_KEY)[0]
        HashWithIndifferentAccess.new(decoded)
    rescue JWT::DecodeError
        nil
    rescue JWT::ExpiredSignature
        "token expired"
    rescue
        nil
    end

end
