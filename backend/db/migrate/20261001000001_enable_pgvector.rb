class EnablePgvector < ActiveRecord::Migration[8.0]
  def up
    enable_extension "vector"
    enable_extension "unaccent"
  end

  def down
    disable_extension "unaccent"
    disable_extension "vector"
  end
end
