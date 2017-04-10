module HelpViewer
  # Help page to be run when given the argument 'help', 'h', '--h' or '--help'
  def self.display_help
    puts "checkin - a tool to integrate mindful checkins into your git workflow\n"
    puts "Wording, advice, and structure for this mindfulness exercise were largely pulled from 'SOS for Emotions' by the NYU Student Health Center, authored by Reji Mathew, PhD, NYU Counseling and Wellness Services, Dialectical Behavior Therapy Clinical Team (https://www.nyu.edu/content/dam/nyu/studentHealthServices/documents/PDFs/mental-health/CWS_SOS_for_Emotions_Booklet.pdf).\n"
    puts "This program is designed to be used when you checkout a git branch, so that you can checkin with yourself before you start on some coding work. If you're feeling somewhat to very intense negative emotions, you're encouraged to address those before you start your work, and leave a note to yourself to be reviewed later.\n"
    puts "This program has four optional arguments:\n"
    puts "help, h, --help, or --h"
    puts "Displays this help screen.\n"
    puts "log, or l, with optional integer"
    puts "Displays a chronological table of all of your previous checkins. Include an integer n to limit the checkins to the previous n, by date.\n"
    puts "pull, or p"
    puts "Review your previous notes to self made through this program.\n"
    puts "hook, or --hook, with optional hook name"
    puts "Attaches this checkin to a githook in the current git repository, so that checkin_self is automatically called every time you run a specific git command for the current repository. Defaults to post-checkout hook if no argument given. See this page for further documentation on githooks: https://git-scm.com/docs/githooks."
  end
end
