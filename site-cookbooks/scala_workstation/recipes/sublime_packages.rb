include_recipe 'pivotal_workstation::sublime_text'

sublime_package_path = ["#{WS_HOME}/Library/Application Support/Sublime Text 2", "Packages"]
sublime_user_path = sublime_package_path.dup << "User"

begin
  t = resources(:template => File.expand_path("Preferences.sublime-settings", File.join(sublime_user_path)))
  t.cookbook "scala_workstation"
end
