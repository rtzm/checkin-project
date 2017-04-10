# checkin_self - a tool to integrate mindful checkins into your git workflow

require 'sqlite3'
require_relative 'emotion_list'
require_relative 'checkin'
require_relative 'checkins_db'
require_relative 'githooker'
require_relative 'help_viewer'

db = CheckinsDB.new(SQLite3::Database.new(File.join(Dir.home, ".checkins.db")))

if ARGV[0]
  option = ARGV[0]
  case option.downcase
  when "help", "h", "--help"
    HelpViewer.display_help
  when "log", "l"
    # set limit to argument given or to extremely high number
    limit = ARGV[1] ||= 99999999999999999999
    puts db.log(limit.to_i)
  when "pull", "p"
    puts db.review_notes
  when "hook", "--hook"
    hook_name = ARGV[1] ||= "post-checkout"
    file_contents = "#!/usr/bin/env ruby\nrequire 'checkin_self'"
    GithookerViewer.display_exit_status(Githooker.hook(hook_name, file_contents))
  end
else
  checkin = Checkin.new
  db.add(checkin.to_h)
end
