# Returns the site name from the vagrant arguments
def site_picker(drush_config_directory)

  # This script can only be used with `vagrant up`
  if ARGV.find_index("up") == nil
    return ""
  end

  result = nil
  # Search drush aliases
  sites = Dir[File.join(drush_config_directory, "*.drushrc.php")].map! {|file| File.basename(file, '.aliases.drushrc.php') }

  if sites.length == 1
    # If this repository contains only one site return it
    return sites[0]

  elsif sites.length > 1
    # If this repository contains multiple sites check the command line

    site_arg = ARGV.select{|arg| arg.match(/^\-\-site=.+/)}

    site = ""
    if site_arg.length > 0 && matches = site_arg[0].match(/^\-\-site=(\S+)\s*$/)
      # Check for the name
      if sites.include?(matches[1])
        site = matches[1]
      elsif sites[Integer(matches[1]) - 1]
        site = sites[Integer(matches[1]) - 1]
      end

      # Remove site argument from vagrant argument list
      ARGV.delete_at(ARGV.find_index(site_arg[0]))
    end

    if site == ""
      puts "Multiple drush configs detected."
      puts "Please specify the config to be used."
      puts "Available sites are: "

      i = 0
      sites.each do |site|
          i=i+1
          puts "  #{i} #{site}"
      end

      puts "Usage: vagrant up --site=1"
      puts "Usage: vagrant up --site=\"#{sites[0]}\""

      exit 1
    end
  end

  return site
end