class SystemPromptSerializer
  include Alba::Resource

  attributes :id, :name, :content, :is_default, :created_at, :updated_at
end
