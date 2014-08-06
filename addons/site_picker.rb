# Choose site configuration.
#
# drush_config_directory - The directory containing *.drushrc.php files.
#
# Returns the site name or an empty string, if only one site exists.
def site_picker(drush_config_directory = "drush_config")

  # This script should only run with vagrant commands "up" and "provision"
  return "" unless ARGV.include?("up") || ARGV.include?("provision")

  # If a stored site config exists and we"re NOT provisioning, use it
  if File.exist?(".site") && ARGV.include?("up") && !ARGV.include?("--provision")
    site = File.read(".site");
    puts "Using previously provisioned site \"#{site}\""
    return site
  end

  # Get names of all drush alias files
  sites = Dir[File.join(drush_config_directory, "*.drushrc.php")].map! { |file| File.basename(file, ".aliases.drushrc.php") }

  if sites.length == 1
    # If this repository contains only one site return it
    return ""

  elsif sites.length > 1
    # If this repository contains multiple sites ask which one to use
    puts "Multiple drush configurations detected. Select site to use:"

    i = 0
    sites.each do |site|
      i = i + 1
      puts "  #{i} #{site}"
    end
    
    site = input = ""
    while input.empty?
      print "Enter site id: "
      input = $stdin.gets.chomp

      # Validate input exists
      if sites.include?(input)
        site = input
      elsif sites[Integer(input) - 1]
        site = sites[Integer(input) - 1]
      end
    end

    File.write(".site", site);
  end

  return site
end


# Forget previously set site configuration.
def site_picker_forget
  File.delete(".site") if File.exist?(".site")
end
