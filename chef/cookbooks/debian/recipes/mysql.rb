# MySql
if !File.exists?('/root/.mysql_recipe_installed')

  package 'mysql-server' do
    action :install
  end

  package 'mysql-client' do
    action :install
  end

  # Generate mysql password
  def generate_random_string(length=6)
    string = ""
    chars = ('a'..'z').to_a + ('A'..'Z').to_a + ('0'..'9').to_a
    length.times{ string << chars[rand(chars.length)] }
    string
  end

  mysql_password = generate_random_string(16)

  bash 'mysql_secure_installation' do
    code <<-EOH
      mysql -uroot <<EOF && touch /root/.mysql_secure_installation_complete
-- remove anonymous users
DELETE FROM mysql.user WHERE User='';
-- Disallow root login remotely
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
-- Remove test database and access to it
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
UPDATE mysql.user SET Password=PASSWORD('#{mysql_password}') WHERE User='root';
FLUSH PRIVILEGES;
-- Reload privilege tables now
FLUSH PRIVILEGES;
EOF
    EOH
    only_if do
      !File.exists?('/root/.mysql_installation_complete')
    end
  end

  file "/root/.my.cnf" do
    content "[client]\npassword=#{mysql_password}\n"
    mode "0644"
    only_if do
      !File.exists?('/root/.mysql_installation_complete')
    end
  end

  service 'mysql' do
    action :restart
  end

  bash 'set marker' do
    code 'touch /root/.mysql_recipe_installed'
  end

end