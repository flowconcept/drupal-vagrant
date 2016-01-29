if !File.exists?('/root/.compass_recipe_installed')

  package 'ruby-compass' do
    action :install
  end

end
