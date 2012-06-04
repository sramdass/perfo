#ActionMailer::Base.delivery_method = :smtp # be sure to choose SMTP delivery
ActionMailer::Base.smtp_settings = {
  :tls => true,
  :address => "smtp.gmail.com",
  :port => 587,
  :domain => "gmail.com",
  :authentication => :plain,
  :user_name => ENV['EMAIL_ID'], # use full email address here
  :password => ENV['EMAIL_PASSWORD']
}

# default url options is given in application_controller.rb
