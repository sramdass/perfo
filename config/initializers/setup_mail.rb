#ActionMailer::Base.delivery_method = :smtp # be sure to choose SMTP delivery
#delivery_method is moved to the development/staging/production.rb files

#IF we are in the development mode, use the gmail account.
#If we are in the staging or production env, use the sendgrid addon provided by heroku

if ENV['EMAIL_ID'] && ENV['EMAIL_PASSWORD']
  ActionMailer::Base.smtp_settings = {
    :tls => true,
    :address => "smtp.gmail.com",
    :port => 587,
    :domain => "gmail.com",
    :authentication => :plain,
    :user_name => ENV['EMAIL_ID'], # use full email address here
    :password => ENV['EMAIL_PASSWORD']
  }
elsif  ENV['SENDGRID_USERNAME'] && ENV['SENDGRID_PASSWORD']
  ActionMailer::Base.smtp_settings = {
    :address        => 'smtp.sendgrid.net',
    :port           => '587',
    :authentication => :plain,
    :user_name      => ENV['SENDGRID_USERNAME'],
    :password       => ENV['SENDGRID_PASSWORD'],
    :domain         => 'heroku.com'
  }
end

# default url options is given in application_controller.rb
