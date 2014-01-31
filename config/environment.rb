# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
R2::Application.initialize!

# Date format
Date::DATE_FORMATS[:default] = '%y/%m/%d'
Time::DATE_FORMATS[:default] = '%y/%m/%d'