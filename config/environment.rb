# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
DeviceLocation::Application.initialize!

# Configure Paperclip
Paperclip.options[:command_path] = "/usr/bin/"
