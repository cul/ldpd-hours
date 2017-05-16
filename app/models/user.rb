class User < ApplicationRecord
  include Cul::Omniauth::Users
  ROLES = %i[admin superadmin]

  def password
  	Devise.friendly_token[0,20]
  end

  def password=(*val)

  end
end
