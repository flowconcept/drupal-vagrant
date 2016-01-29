if !File.exists?('/root/.compass_recipe_installed')

  package 'ruby_compass' do
    action :install
  end

end
