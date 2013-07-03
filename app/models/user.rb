class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

     acts_as_messageable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :profile_pic
  # attr_accessible :title, :body

  has_attached_file :profile_pic, :styles => {:small=> "100X100>", :thumb => "40X40>"}, 
  :default_url => 'assets/default_profilepic_#{size}.png'

  def name
  	return :email
  end

  def user_image(size)
  if profile_pic.present?
    return profile_pic.url(size)
  else
    return "/assets/default_profilepic_#{size}.jpg"
  end
end

end
