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

    puts "Multiple drush configs detected."
    puts "Please specify the config to be used."
    puts "Available sites are: "

    i = 0
    sites.each do |site|
      i=i+1
      puts "  #{i} #{site}"
    end
    puts "Enter site id:"
    input = $stdin.gets

    site = ""
    if input.length > 0
      # Check for the name
      if sites.include?(input)
        site = input
      elsif sites[Integer(input) - 1]
        site = sites[Integer(input) - 1]
      end

      # Remove site argument from vagrant argument list
      #ARGV.delete_at(ARGV.find_index(input))
    end
  end

  return site
end
