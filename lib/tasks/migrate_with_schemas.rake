desc 'Migrates all postgres schemas'
namespace :db do
task :migrate_schemas do
  if ENV['DATABASE_URL']
    env = "#{ENV['RACK_ENV']}"  	
    config = URI.parse(ENV['DATABASE_URL'])
    ActiveRecord::Base.establish_connection(
							    :adapter  => config.scheme == 'postgres' ? 'postgresql' : db.scheme,
							    :host     => config.host,
							    :username => config.user,
							    :password => config.password,
							    :database => config.path[1..-1],
							    :encoding => Rails.env == 'development' ? 'unicode' : 'utf8'
								)
  else    
    env = "#{Rails.env}"
    config = YAML::load(File.open('config/database.yml'))
    ActiveRecord::Base.establish_connection(config[env])
  end  
  puts "Migratin in Environment: #{env}"  
  schemas = ActiveRecord::Base.connection.select_values("select * from pg_namespace where nspname != 'information_schema' AND nspname NOT LIKE 'pg%'")
  puts "Migrate schemas: #{schemas.inspect}"
  # migrate each schema
  schemas.each do |schema|
    puts "Migrate schema: #{schema}"
    ActiveRecord::Base.connection.schema_search_path=schema
    #config[env]["schema_search_path"] = schema
    #ActiveRecord::Base.establish_connection(config[env])
    ActiveRecord::Base.logger = Logger.new(STDOUT)
    ActiveRecord::Migrator.migrate('db/migrate', ENV["VERSION"] ? ENV["VERSION"].to_i : nil)
  end
end
end