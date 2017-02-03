class Planocore < ApplicationRecord
  def self.controller
    "```ruby
    def create
      employee = Employee.new(employee_params)
      employee.user.person.vendor_id = @session.user.person.vendor.id
      validate_action(employee.planoadmin_read_view, 'Employee created.', Proc.new { employee.save })
    end

    def read
      employee = params[:id] ? Employee.find(params[:id]) : nil
      validate_action(employee.planoadmin_read_view, 'Employee read.')
    end

    def update
      employee = params[:id] ? Employee.find(params[:id]) : nil
      validate_action(employee.planoadmin_read_view, 'Employee updated.', Proc.new { employee.update(employee_params) })
    end
    "
  end
  def self.employee_model
    "```ruby
    belongs_to :user
    belongs_to :department

    has_many :users_roles, as: :users_roleable
    has_many :roles, :through => :users_roles  # Edit :needs to be plural same as the has_many relationship

    accepts_nested_attributes_for :user
    accepts_nested_attributes_for :users_roles, allow_destroy: true

    # PlanoAdmin | Used for the employee index in PlanoAdmin's Employees page.
    def self.planoadmin_index_view
      all.map do |employee|
        employee.planoadmin_index_view
      end
    end
    def planoadmin_index_view
      {
        model: self,
        user: user.and_person
      }
    end
    # PlanoAdmin | Used for the employee read in PlanoAdmin's Employees page.
    def planoadmin_read_view
      {
        model: self,
        errors: errors,
        user: user.and_person,
        users_roles: users_roles
      }
    end
    # Utility | Used in many places to return the employee and their user/person data.
    def and_user
      {
        model: self,
        user: user.and_person
      }
    end
    # Utility | Returns employee's role for the passed in application
    def role_in(application = nil)
      nil if application.nil?
      roles.find_by_application_id(application.id)
    end

    "
  end
  def self.user_model
    "```ruby
    has_one :employee
    belongs_to :person
    has_many :sessions
    has_many :history_logs
    has_many :preferences, as: :preferenceable

    has_many :employees_roles, through: :employee, source: :users_roles, as: :users_roleable
    has_many :employee_roles, through: :employees_roles, source: :role

    has_many :images, as: :imageable, dependent: :destroy

    # accepts_nested_attributes_for :users_roles, allow_destroy: true
    accepts_nested_attributes_for :images
    accepts_nested_attributes_for :preferences
    has_secure_password
    validates :password, :on => :create, :length => {:within => 6..40}, :confirmation => true, :presence => true
    validates :password, :on => :update, :length => {:within => 6..40}, :confirmation => true, :allow_blank => true
    # PlanoAdmin | Used for the contacts index in PlanoAdmin's Vendors page.
    def planoadmin_index_view
      {
        model: self,
        person: person,
        avatar: image(:avatar)
      }
    end
    # Utility | Used in many places to return a slug of the user's information.
    def slugify
      person.slugify
    end
    # Utility | Used in many places to return the user and their person data.
    def and_person
      {
        model: self,
        person: person,
        avatar: image(:avatar)
      }
    end
    # Utility | Returns user's image and asset based on key.
    def image(key=:avatar)
      images.find_by_key(key).try(:and_asset)
    end
    # Authorization | Validates user can access record.
    def can_access(record)
      record.is_a? User && record.id = id
    end
    # Preferences | Returns hash of preferences.
    def read_preferences
      Hash[list_of_preferences.collect do |key|
        [key, format_preference(key)]
      end]
    end
    # Preferences | Formates a preference object from key.
    def format_preference(key)
      preference = self.preferences.find_by_key(key)
      {
        id: preference ? preference.id : nil,
        value: preference ? preference.format_value : false,
        readable: preference ? preference.readable : nil
      }
    end
    def remember_me
      preferences.find_by_key('remember_me').try(:value)
    end
    # Authentication | Create a new session and update user's remember_me preference.
    def new_login(application, remember_me=false)
      preferences.find_or_create_by(key: 'remember_me').update(value: remember_me)
      new_session(application)
    end
    # Authentication | Deletes user's previous sessions in application and creates a new one.
    def new_session(application)
      sessions.where(application_id: application.id, active: true).update(active: false)
      sessions.create(application_id: application.id, active: true)
    end
    # Authentication | Used to encrypt a token.
    def encrypt(token)
      crypt = ActiveSupport::MessageEncryptor.new(ENV['session_token_secret'])
      encrypted_data = crypt.encrypt_and_sign(token)
    end
    # Authentication | Used to generate a unique token.
    def generate_token(column)
      begin
        self[column] = SecureRandom.urlsafe_base64
      end while User.exists?(column => self[column])
    end
    # Authentication | Send password reset email.
    def send_password_reset(application)
      # Generate new password_reset_token.
      generate_token(:password_reset_token)
      self.password_reset_sent_at = Time.now
      save!
      # Encrypt token.
      encrypted_token = encrypt(password_reset_token)
      # Send email.
      UserMailer.password_reset(self, encrypted_token, application).deliver
    end
    # Upload | Upload image.
    def upload_image(file)
      # Init S3 buckets.
      temp_bucket = S3.temp_bucket
      images_bucket = S3.bucket('g2-image-files')
      # Normalize key.
      key = file[:key] || :avatar
      # Build S3 path.
      s3_file_path = 'self.class.name.underscore.pluralize/id/slugify/key'
      # Transfer file from temp bucket to long-term bucket.
      S3.transfer_bucket(temp_bucket, file, images_bucket, s3_file_path)
      # Create Image record.
      image = images.find_or_create_by(key: key)
      # Create Asset record.
      image.create_asset(file_size: file[:size], content_type: file[:type], file_path: 'https://s3.amazonaws.com/images_bucket.name/s3_file_path')
    end
    # Logs | Returns tours viewed.
    def tours_history_logs
      history_logs.where(application_id: Application.planox, history_logable_type: 'Tour').order(created_at: :desc).limit(10)
    end
    "
  end
end



#
# has_one :employee
# belongs_to :person
# has_many :sessions
# has_many :history_logs
# has_many :preferences, as: :preferenceable
#
# has_many :employees_roles, through: :employee, source: :users_roles, as: :users_roleable
# has_many :employee_roles, through: :employees_roles, source: :role
#
# has_many :images, as: :imageable, dependent: :destroy
#
# # accepts_nested_attributes_for :users_roles, allow_destroy: true
# accepts_nested_attributes_for :images
# accepts_nested_attributes_for :preferences
# has_secure_password
# validates :password, :on => :create, :length => {:within => 6..40}, :confirmation => true, :presence => true
# validates :password, :on => :update, :length => {:within => 6..40}, :confirmation => true, :allow_blank => true
# # PlanoAdmin | Used for the contacts index in PlanoAdmin's Vendors page.
# def planoadmin_index_view
#   {
#     model: self,
#     person: person,
#     avatar: image(:avatar)
#   }
# end
# # Utility | Used in many places to return a slug of the user's information.
# def slugify
#   person.slugify
# end
# # Utility | Used in many places to return the user and their person data.
# def and_person
#   {
#     model: self,
#     person: person,
#     avatar: image(:avatar)
#   }
# end
# # Utility | Returns user's image and asset based on key.
# def image(key=:avatar)
#   images.find_by_key(key).try(:and_asset)
# end
# # Authorization | Validates user can access record.
# def can_access(record)
#   record.is_a? User && record.id = id
# end
# # Preferences | Returns hash of preferences.
# def read_preferences
#   Hash[list_of_preferences.collect do |key|
#     [key, format_preference(key)]
#   end]
# end
# # Preferences | Formates a preference object from key.
# def format_preference(key)
#   preference = self.preferences.find_by_key(key)
#   {
#     id: preference ? preference.id : nil,
#     value: preference ? preference.format_value : false,
#     readable: preference ? preference.readable : nil
#   }
# end
# def remember_me
#   preferences.find_by_key('remember_me').try(:value)
# end
# # Authentication | Create a new session and update user's remember_me preference.
# def new_login(application, remember_me=false)
#   preferences.find_or_create_by(key: 'remember_me').update(value: remember_me)
#   new_session(application)
# end
# # Authentication | Deletes user's previous sessions in application and creates a new one.
# def new_session(application)
#   sessions.where(application_id: application.id, active: true).update(active: false)
#   sessions.create(application_id: application.id, active: true)
# end
# # Authentication | Used to encrypt a token.
# def encrypt(token)
#   crypt = ActiveSupport::MessageEncryptor.new(ENV['session_token_secret'])
#   encrypted_data = crypt.encrypt_and_sign(token)
# end
# # Authentication | Used to generate a unique token.
# def generate_token(column)
#   begin
#     self[column] = SecureRandom.urlsafe_base64
#   end while User.exists?(column => self[column])
# end
# # Authentication | Send password reset email.
# def send_password_reset(application)
#   # Generate new password_reset_token.
#   generate_token(:password_reset_token)
#   self.password_reset_sent_at = Time.now
#   save!
#   # Encrypt token.
#   encrypted_token = encrypt(password_reset_token)
#   # Send email.
#   UserMailer.password_reset(self, encrypted_token, application).deliver
# end
# # Upload | Upload image.
# def upload_image(file)
#   # Init S3 buckets.
#   temp_bucket = S3.temp_bucket
#   images_bucket = S3.bucket('g2-image-files')
#   # Normalize key.
#   key = file[:key] || :avatar
#   # Build S3 path.
#   s3_file_path = "#{self.class.name.underscore.pluralize}/#{id}/#{slugify}/#{key}-#{rand(100)}#{Asset.suffix(file[:type])}"
#   # Transfer file from temp bucket to long-term bucket.
#   S3.transfer_bucket(temp_bucket, file, images_bucket, s3_file_path)
#   # Create Image record.
#   image = images.find_or_create_by(key: key)
#   # Create Asset record.
#   image.create_asset(file_size: file[:size], content_type: file[:type], file_path: "https://s3.amazonaws.com/#{images_bucket.name}/#{s3_file_path}")
# end
# # Logs | Returns tours viewed.
# def tours_history_logs
#   history_logs.where(application_id: Application.planox, history_logable_type: 'Tour').order(created_at: :desc).limit(10)
# end
#
#
#
#
# # belongs_to :user
# # belongs_to :department
# #
# # has_many :users_roles, as: :users_roleable
# # has_many :roles, :through => :users_roles  # Edit :needs to be plural same as the has_many relationship
# #
# # accepts_nested_attributes_for :user
# # accepts_nested_attributes_for :users_roles, allow_destroy: true
# #
# # # PlanoAdmin | Used for the employee index in PlanoAdmin's Employees page.
# # def self.planoadmin_index_view
# #   all.map do |employee|
# #     employee.planoadmin_index_view
# #   end
# # end
# # def planoadmin_index_view
# #   {
# #     model: self,
# #     user: user.and_person
# #   }
# # end
# # # PlanoAdmin | Used for the employee read in PlanoAdmin's Employees page.
# # def planoadmin_read_view
# #   {
# #     model: self,
# #     errors: errors,
# #     user: user.and_person,
# #     users_roles: users_roles
# #   }
# # end
# # # Utility | Used in many places to return the employee and their user/person data.
# # def and_user
# #   {
# #     model: self,
# #     user: user.and_person
# #   }
# # end
# # # Utility | Returns employee's role for the passed in application
# # def role_in(application = nil)
# #   nil if application.nil?
# #   roles.find_by_application_id(application.id)
# # end
