class User < ApplicationRecord
  include Cul::Omniauth::Users
  ROLES = %i[admin superadmin]
  before_validation :add_email

  def password
  	Devise.friendly_token[0,20]
  end

  def password=(*val)

  end

  private

  def add_email
  	if self.uid.present?
  		self.email = self.uid + "@columbia.edu"
  	else
  		return false
  	end
  end

end
