class TenantManager < ActiveRecord::Base
  self.abstract_class = true	
    #Since we are using the same user id and password for all the TenantManager connections, we will have ony one
    #TenantManager connection per process. We do need a new connection for every request. We cannot use the 
    #ActiveRecord::Base because  - to have two different schema path at the same time, we need two different connections.
	if ENV['DATABASE_URL']
  	  db_config = URI.parse(ENV['DATABASE_URL'])
	  establish_connection(
									    :adapter  => db_config.scheme == 'postgres' ? 'postgresql' : db.scheme,
									    :host     => db_config.host,
									    :username => db_config.user,
									    :password => db_config.password,
									    :database => db_config.path[1..-1],
									    :encoding => Rails.env == 'development' ? 'unicode' : 'utf8'
		    							)
  elsif
    db_config = Rails.configuration.database_configuration[Rails.env]
	establish_connection(
	  									:adapter =>db_config["adapter"],
										:encoding => db_config["encoding"],
										:database => db_config["database"],
										:pool => db_config["pool"],
										:username => db_config["username"],
										:password => db_config["password"],
										:port => db_config["port"]
	  									)
  end
end
