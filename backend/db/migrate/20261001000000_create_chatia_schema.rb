class CreateChatiaSchema < ActiveRecord::Migration[8.0]
  def up
    # Cria o schema isolado para este projeto dentro do banco compartilhado.
    # Usa execute diretamente pois ActiveRecord não tem DSL para CREATE SCHEMA.
    execute "CREATE SCHEMA IF NOT EXISTS chatia"
  end

  def down
    # Só remove se não houver objetos dentro — proteção contra drop acidental.
    execute "DROP SCHEMA IF EXISTS chatia RESTRICT"
  end
end
