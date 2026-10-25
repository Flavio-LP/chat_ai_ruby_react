class UserSerializer
  include Alba::Resource

  attributes :id, :name, :email, :created_at
end
