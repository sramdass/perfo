desc 'Migrates all postgres schemas'
namespace :db do
task :migrate_schemas do
  # get all schemas
  puts "Migratin in Environment: #{Rails.env}"
  env = "#{Rails.env}"
  if ENV['DATABASE_URL']
    config = URI.parse(ENV['DATABASE_URL'])
  else    
    config = YAML::load(File.open('config/database.yml'))
  end  
  ActiveRecord::Base.establish_connection(config[env])
  schemas = ActiveRecord::Base.connection.select_values("select * from pg_namespace where nspname != 'information_schema' AND nspname NOT LIKE 'pg%'")
  puts "Migrate schemas: #{schemas.inspect}"
  # migrate each schema
  schemas.each do |schema|
    puts "Migrate schema: #{schema}"
	if ENV['DATABASE_URL']
  	  config = URI.parse(ENV['DATABASE_URL'])
  	else    
      config = YAML::load(File.open('config/database.yml'))
    end
    config[env]["schema_search_path"] = schema
    ActiveRecord::Base.establish_connection(config[env])
    ActiveRecord::Base.logger = Logger.new(STDOUT)
    ActiveRecord::Migrator.migrate('db/migrate', ENV["VERSION"] ? ENV["VERSION"].to_i : nil)
  end
end
end