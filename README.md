# checkin-project

checkin_self - a tool to integrate mindful checkins into your git workflow

Wording, advice, and structure for this mindfulness exercise were largely pulled from 'SOS for Emotions' by the NYU Student Health Center, authored by Reji Mathew, PhD, NYU Counseling and Wellness Services, Dialectical Behavior Therapy Clinical Team (https://www.nyu.edu/content/dam/nyu/studentHealthServices/documents/PDFs/mental-health/CWS_SOS_for_Emotions_Booklet.pdf).

This program is designed to be used when you checkout a git branch, so that you can checkin with yourself before you start on some coding work. If you're feeling somewhat to very intense negative emotions, you're encouraged to address those before you start your work, and leave a note to yourself to be reviewed later.

This program has four optional arguments:

- hook, or --hook, with optional hook name as second argument

  - Attaches this checkin to a githook in the current git repository, so that checkin_self is automatically called every time you run a specific git command for the current repository. Defaults to post-checkout hook if no argument given. See this page for further documentation on githooks: https://git-scm.com/docs/githooks.

- log, or l, with optional integer

  - Displays a chronological table of all of your previous checkins. Include an integer n to limit the checkins to the previous n, by date.

- pull, or p

  - Review your previous notes to self made through this program.

- help, h, --help, or --h

  - Displays help screen.

If you've installed this as a gem, you should be able to run it just by typing `checkin_self' into bash, with optional arguments.

Future changes to be made:

- Changing from a sqlite database to some flatter data storage?
- making a gemfile to alert sqlite dependencies
- improving object-oriented design
- Use highline to improve the readability of the text in command-line