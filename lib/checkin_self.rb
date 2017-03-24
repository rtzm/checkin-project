# checkin_self - a tool to integrate mindful checkins into your git workflow

# BUSINESS LOGIC

require 'sqlite3'
require_relative 'emotion_list'
require_relative 'checkin'
require_relative 'checkins_db'
require_relative 'githooker'

db = CheckinsDB.new(SQLite3::Database.new(File.join(Dir.home, ".checkins.db")))

# Help page to be run when given the argument 'help', 'h', '--h' or '--help'
def display_help
  puts "checkin - a tool to integrate mindful checkins into your git workflow"
  puts
  puts "Wording, advice, and structure for this mindfulness exercise were largely pulled from 'SOS for Emotions' by the NYU Student Health Center, authored by Reji Mathew, PhD, NYU Counseling and Wellness Services, Dialectical Behavior Therapy Clinical Team (https://www.nyu.edu/content/dam/nyu/studentHealthServices/documents/PDFs/mental-health/CWS_SOS_for_Emotions_Booklet.pdf)."
  puts
  puts "This program is designed to be used when you checkout a git branch, so that you can checkin with yourself before you start on some coding work. If you're feeling somewhat to very intense negative emotions, you're encouraged to address those before you start your work, and leave a note to yourself to be reviewed later."
  puts
  puts "This program has four optional arguments:"
  puts
  puts "help, h, --help, or --h"
  puts "Displays this help screen."
  puts
  puts "log, or l, with optional integer"
  puts "Displays a chronological table of all of your previous checkins. Include an integer n to limit the checkins to the previous n, by date."
  puts
  puts "pull, or p"
  puts "Review your previous notes to self made through this program."
  puts
  puts "hook, or --hook, with optional hook name"
  puts "Attaches this checkin to a githook in the current git repository, so that checkin_self is automatically called every time you run a specific git command for the current repository. Defaults to post-checkout hook if no argument given. See this page for further documentation on githooks: https://git-scm.com/docs/githooks."
end

# DRIVER CODE

# parse arguments passed to program
if ARGV[0]
  option = ARGV[0]
  case option.downcase
  when "help", "h", "--help"
    display_help
  when "log", "l"
    if ARGV[1]
      puts db.log(ARGV[1].to_i)
    else
      puts db.log(Float::INFINITY)
    end
  when "pull", "p"
    puts db.review_notes
  when "hook", "--hook"
    hook_name = ARGV[1] ||= "post-checkout"
    file_contents = ""
    file_contents += "#!/usr/bin/env ruby"
    file_contents += "\n"
    file_contents += "require 'checkin_self'"
    file_contents += "\n"
    Githooker.hook(hook_name, file_contents)
  end
else
  checkin = Checkin.new
  db.add(checkin.to_h)
end