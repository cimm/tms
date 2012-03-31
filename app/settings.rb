require "settingslogic"

class Settings < Settingslogic
  source "settings.yml"
  namespace ENV['ENV'] || "default"
end
