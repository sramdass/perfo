module PgTools
  extend self
  
  def default_search_path
    "public"
  end
  
  def restore_default_search_path
    get_connection.schema_search_path = default_search_path
  end  
  
  def set_search_path(name)
    get_connection.schema_search_path = name
  end
  
  def create_schema(name)
  	if schemas.include?(name)
  	  #Raise an exception here
  	else
      sql = %{CREATE SCHEMA #{name}}
      get_connection.execute sql
    end
  end

  def delete_schema(name)
  	#The schema's wont be present until the tenant signs up (provide a subdomain)
  	#This condition is necessary when the admin creates a tenant and has to delete
  	#the tenant before the tenant signs up.
  	if schemas.include?(name)
      sql = %{DROP SCHEMA #{name} CASCADE}
      get_connection.execute sql
    else
      #Log here
    end
  end  
  
  def create_tenant(user_name, password)
    sql = %{CREATE USER #{user_name} WITH PASSWORD '#{password}'}
    get_connection.execute sql	
  end
  
  def grant_permissions(user_name, schema_name)
    sql = %{GRANT USAGE ON SCHEMA #{schema_name} TO #{user_name}}
    get_connection.execute sql  	
  	sql = %{GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA #{schema_name} TO #{user_name}}
    get_connection.execute sql
    sql = %{GRANT SELECT, UPDATE ON ALL SEQUENCES IN SCHEMA #{schema_name} TO #{user_name}}
    get_connection.execute sql
    sql = %{GRANT SELECT ON TABLE public.tenants TO #{user_name}}
    get_connection.execute sql
  end

  def schemas
    sql = "SELECT nspname FROM pg_namespace WHERE nspname !~ '^pg_.*'"
    get_connection.query(sql).flatten
  end
  
  def get_connection
    ActiveRecord::Base.connection
  end

end

