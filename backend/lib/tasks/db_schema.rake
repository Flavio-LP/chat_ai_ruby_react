namespace :db do
  # Garante que o schema chatia existe antes de db:migrate criar schema_migrations.
  # Necessário porque database.yml usa schema_search_path: chatia,public num banco compartilhado.
  task ensure_schema: :environment do
    schema = ENV.fetch("DB_SCHEMA", "chatia")
    ActiveRecord::Base.connection.execute(
      "CREATE SCHEMA IF NOT EXISTS #{ActiveRecord::Base.connection.quote_column_name(schema)}"
    )
    puts "Schema '#{schema}' pronto."
  end

  Rake::Task["db:migrate"].enhance(["db:ensure_schema"])
end
