# checkin - a tool to integrate mindful checkins into your git workflow
# Wording, advice, and structure for this mindfulness exercise were largely pulled from "SOS for Emotions" by the NYU Student Health Center, authored by Reji Mathew, PhD, NYU Counseling and Wellness Services, Dialectical Behavior Therapy Clinical Team (https://www.nyu.edu/content/dam/nyu/studentHealthServices/documents/PDFs/mental-health/CWS_SOS_for_Emotions_Booklet.pdf).
# To use this program, call it without arguments. If you call it with the argument 'log', you can get a report on your previous checkins.

# BUSINESS LOGIC

require 'sqlite3'
require_relative 'emotion_list'

db = SQLite3::Database.new(File.join(Dir.home, ".checkins.db"))

# SQL command to make the tables if they don't exist.
create_tables_cmd = <<-SQL
CREATE TABLE IF NOT EXISTS emotions(
  id INT PRIMARY KEY,
  name VARCHAR(32)
  );
CREATE TABLE IF NOT EXISTS states(
  id INT PRIMARY KEY,
  name VARCHAR(32),
  emotionID INT,
  FOREIGN KEY (emotionID) REFERENCES emotions(id)
  );
CREATE TABLE IF NOT EXISTS checkins(
  time VARCHAR(32) PRIMARY KEY,
  emotionID INT,
  stateID INT,
  intensity INT,
  trigger VARCHAR(255),
  noteToSelf BLOB,
  FOREIGN KEY (emotionID) REFERENCES emotions(id),
  FOREIGN KEY (stateID) REFERENCES state(id)
  );
SQL

db.execute_batch(create_tables_cmd)

# Check if the emotions and states tables have been populated, and, if not, do so.
unless db.execute("SELECT name FROM emotions;").any? { |row| row[0] == "joy" }
  populate_emotional_states_cmd = <<-SQL
  INSERT OR IGNORE INTO emotions (id, name) VALUES (1, "anger");
  INSERT OR IGNORE INTO emotions (id, name) VALUES (2, "joy");
  INSERT OR IGNORE INTO emotions (id, name) VALUES (3, "sadness");
  INSERT OR IGNORE INTO emotions (id, name) VALUES (4, "hurt");
  INSERT OR IGNORE INTO emotions (id, name) VALUES (5, "fear");
  INSERT OR IGNORE INTO states (id, name, emotionID) VALUES (1, "bothered", 1);
  INSERT OR IGNORE INTO states (id, name, emotionID) VALUES (2, "annoyed", 1);
  INSERT OR IGNORE INTO states (id, name, emotionID) VALUES (3, "bitter", 1);
  INSERT OR IGNORE INTO states (id, name, emotionID) VALUES (4, "angry", 1);
  INSERT OR IGNORE INTO states (id, name, emotionID) VALUES (5, "irritated", 1);
  INSERT OR IGNORE INTO states (id, name, emotionID) VALUES (6, "disgusted", 1);
  INSERT OR IGNORE INTO states (id, name, emotionID) VALUES (7, "frustrated", 1);
  INSERT OR IGNORE INTO states (id, name, emotionID) VALUES (8, "exasperated", 1);
  INSERT OR IGNORE INTO states (id, name, emotionID) VALUES (9, "furious", 1);
  INSERT OR IGNORE INTO states (id, name, emotionID) VALUES (10, "content", 2);
  INSERT OR IGNORE INTO states (id, name, emotionID) VALUES (11, "peaceful", 2);
  INSERT OR IGNORE INTO states (id, name, emotionID) VALUES (12, "relaxed", 2);
  INSERT OR IGNORE INTO states (id, name, emotionID) VALUES (13, "cheerful", 2);
  INSERT OR IGNORE INTO states (id, name, emotionID) VALUES (14, "satisfied", 2);
  INSERT OR IGNORE INTO states (id, name, emotionID) VALUES (15, "joyous", 2);
  INSERT OR IGNORE INTO states (id, name, emotionID) VALUES (16, "excited", 2);
  INSERT OR IGNORE INTO states (id, name, emotionID) VALUES (17, "ecstatic", 2);
  INSERT OR IGNORE INTO states (id, name, emotionID) VALUES (18, "happy", 2);
  INSERT OR IGNORE INTO states (id, name, emotionID) VALUES (19, "sad", 3);
  INSERT OR IGNORE INTO states (id, name, emotionID) VALUES (20, "depressed", 3);
  INSERT OR IGNORE INTO states (id, name, emotionID) VALUES (21, "distraught", 3);
  INSERT OR IGNORE INTO states (id, name, emotionID) VALUES (22, "despair", 3);
  INSERT OR IGNORE INTO states (id, name, emotionID) VALUES (23, "melancholy", 3);
  INSERT OR IGNORE INTO states (id, name, emotionID) VALUES (24, "grief", 3);
  INSERT OR IGNORE INTO states (id, name, emotionID) VALUES (25, "helpless", 3);
  INSERT OR IGNORE INTO states (id, name, emotionID) VALUES (26, "hopeless", 3);
  INSERT OR IGNORE INTO states (id, name, emotionID) VALUES (27, "miserable", 3);
  INSERT OR IGNORE INTO states (id, name, emotionID) VALUES (28, "lonely", 4);
  INSERT OR IGNORE INTO states (id, name, emotionID) VALUES (29, "homesick", 4);
  INSERT OR IGNORE INTO states (id, name, emotionID) VALUES (30, "abandoned", 4);
  INSERT OR IGNORE INTO states (id, name, emotionID) VALUES (31, "embarrassed", 4);
  INSERT OR IGNORE INTO states (id, name, emotionID) VALUES (32, "shame", 4);
  INSERT OR IGNORE INTO states (id, name, emotionID) VALUES (33, "guilt", 4);
  INSERT OR IGNORE INTO states (id, name, emotionID) VALUES (34, "foolish", 4);
  INSERT OR IGNORE INTO states (id, name, emotionID) VALUES (35, "humiliated", 4);
  INSERT OR IGNORE INTO states (id, name, emotionID) VALUES (36, "uncertain", 5);
  INSERT OR IGNORE INTO states (id, name, emotionID) VALUES (37, "worried", 5);
  INSERT OR IGNORE INTO states (id, name, emotionID) VALUES (38, "anxious", 5);
  INSERT OR IGNORE INTO states (id, name, emotionID) VALUES (39, "frightened", 5);
  INSERT OR IGNORE INTO states (id, name, emotionID) VALUES (40, "scared", 5);
  INSERT OR IGNORE INTO states (id, name, emotionID) VALUES (41, "nervous", 5);
  INSERT OR IGNORE INTO states (id, name, emotionID) VALUES (42, "afraid", 5);
  INSERT OR IGNORE INTO states (id, name, emotionID) VALUES (43, "terrified", 5);
  INSERT OR IGNORE INTO states (id, name, emotionID) VALUES (44, "overwhelmed", 5);
  SQL
  db.execute_batch(populate_emotional_states_cmd)
end

# Print list of emotions, stored in emotion_list.rb for easier reference
def print_emotion_list
  EMOTION_LIST.each do |emotion, states|
    puts emotion.upcase + ":"
    puts "   " + states.join(", ")
  end
end

# Breathing exercise to be run if the intensity of negative emotions is greater than 5
def breathing_exercise
  4.times do
    4.times { |n| puts "BREATHE IN  " + (">" * (n+1)) + ("." * (3-n)); sleep 1 }
    4.times { |n| puts "    HOLD    " + ("=" * 4); sleep 1 }
    4.times { |n| puts "BREATHE OUT " + ("<" * (4 - n)) + ("." * n); sleep 1 }
  end
end

# Add this checkin into the checkins database in checkins.db
def add_checkin(db, emotional_state, intensity, trigger_note, note_to_self)
  # look up the emotion ID and state ID for a given emotion and state contained in emotional_state hash
  emotion_id = db.get_first_value("SELECT id FROM emotions WHERE name = ?", emotional_state[:emotion])
  if emotional_state[:state]
    state_id = db.get_first_value("SELECT id FROM states WHERE name = ?", emotional_state[:state])
  else
    state_id = nil
  end

  # format current time as a string and note_to_self as a blob
  time_now = Time.now.strftime("%Y-%m-%d %H:%M:%S")
  note_to_self = note_to_self.to_blob if note_to_self

  db.execute("INSERT INTO checkins (time, emotionID, stateID, intensity, trigger, noteToSelf) VALUES (?, ?, ?, ?, ?, ?)", [time_now, emotion_id, state_id, intensity ||= nil, trigger_note ||= nil, note_to_self ||= nil])
end

# used to add some mindful wait time so user can observe emotions
def pause_for(seconds)
  seconds.times { |s| print ((seconds - s).to_s + "... ") ; sleep 1 }
  puts
end

# used to put the feeling that the user feels into terms readable for our databases
def categorize_feeling(feeling)
  if feeling.downcase == "more"
    puts
    print_emotion_list
    puts
    puts "Pick a word from the list above that describes how you're feeling right now."
    return categorize_feeling(gets.chomp)
  elsif EMOTION_LIST.keys.include?(feeling.downcase)
    # emotion named by user, but not a secondary state
    categorized = { emotion: feeling.downcase, state: nil }
  else
    matching_emotion = EMOTION_LIST.select {|emotion, states| states.include? feeling.downcase}
    categorized = { emotion: matching_emotion.keys[0], state: feeling.downcase }
  end
  return categorized if defined? categorized
  # User gave invalid input, run again
  return categorize_feeling("more")
end

# Read in list of tasks that the user wants to remember for later.
def get_tasks
  note_to_self = ""
  task = gets.chomp
  until task.downcase == "done"
    note_to_self += " o " + task + "\n"
    task = gets.chomp
  end
  return note_to_self.chomp
end

# Help page to be run when given the argument 'help', 'h', '--h' or '--help'
def display_help
  puts "checkin - a tool to integrate mindful checkins into your git workflow"
  puts
  puts "Wording, advice, and structure for this mindfulness exercise were largely pulled from 'SOS for Emotions' by the NYU Student Health Center, authored by Reji Mathew, PhD, NYU Counseling and Wellness Services, Dialectical Behavior Therapy Clinical Team (https://www.nyu.edu/content/dam/nyu/studentHealthServices/documents/PDFs/mental-health/CWS_SOS_for_Emotions_Booklet.pdf)."
  puts
  puts "This program is designed to be used when you checkout a git branch, so that you can checkin with yourself before you start on some coding work. If you're feeling somewhat to very intense negative emotions, you're encouraged to address those before you start your work, and leave a note to yourself to be reviewed later."
  puts
  puts "This program has three optional arguments:"
  puts
  puts "help, h, --help, or --h"
  puts "Displays this help screen."
  puts
  puts "log, or l, with optional integer"
  puts "Displays a chronological table of all of your previous checkins. Include an integer n to limit the checkins to the previous n, by date."
  puts
  puts "pull, or p"
  puts "Review your previous notes to self made through this program."
  exit
end

def print_log(db, limit=Float::INFINITY)
  # generate SQL query that can pull the log, replace the ids from each table with the emotion/state names, etc
  qry_checkins_cmd = <<-SQL
  SELECT time, emotions.name, states.name, intensity
  FROM (checkins LEFT JOIN emotions ON checkins.emotionID = emotions.id) LEFT JOIN states
  ON checkins.stateID = states.id;
  SQL

  # make header row
  puts "Checkin time         | Emotion      | Emotional state  | Intensity "
  puts "---------------------|--------------|------------------|-----------"

  # initialize incrementer to test if going past limit
  i = 1

  # print that SQL query for each row, going back as long as incrementer is less than limit
  rows = db.execute(qry_checkins_cmd)
  rows.reverse_each do |row|
    next if i > limit

    # turn all null or nil values and all numbers into strings
    row.map!(&:to_s)
    puts row[0].ljust(21) + "| " + row[1].ljust(13) + "| " + row[2].ljust(17) + "| " + row[3].ljust(9)
    i += 1
  end
  exit
end

def review_notes_to_self(db)
  # generate SQL queries that pull the times and all from the noteToSelf attribute, numbered

  pull_notes_cmd = <<-SQL
  SELECT time, emotions.name, states.name, trigger, noteToSelf
  FROM (checkins JOIN emotions ON checkins.emotionID = emotions.id) LEFT JOIN states
  ON checkins.stateID = states.id;
  SQL
  entries = db.execute(pull_notes_cmd)
  puts
  entries.each do |entry|
    next unless entry[3] or entry[4]
    puts "Date and time: " + entry[0]
    print "Emotional state: " + entry[1]
    print ", " + entry[2] if entry[2] # checking if state is nil
    print "\n"
    puts "Trigger: " + entry[3] if entry[3]
    puts
    puts "Note to self: \n\n" + entry[4] if entry[4]
    puts
    puts " -=- -=- -=- -=- -=- -=- -=- -=- "
    puts
  end
  exit
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
      print_log(db, ARGV[1].to_i)
    else
      print_log(db)
    end
  when "pull", "p"
    review_notes_to_self(db)
  end
end

# begin main checkin process

puts
puts "OBSERVE how you're feeling."
puts "No need to judge it, let's just pause and notice it."

pause_for(25)

puts "DESCRIBE how you're feeling. Which of these emotions would you say it falls under?"
puts
puts "anger -=- joy -=- sadness -=- hurt -=- fear"
puts
puts "Type 'more' for a list of more words to help you figure out what you're feeling and how we'll categorize it."

emotional_state = categorize_feeling(gets.chomp)
puts

puts "How strong is that feeling on a scale of 0 to 10?"
intensity = gets.chomp.to_i
intensity = 0 if intensity < 0
intsensity = 10 if intensity > 10
puts

# begin intervention due to high negative emotions
if intensity > 5 and emotional_state[:emotion] != "joy"
  puts "Okay, let's take a couple of breaths, then let's talk about our options."
  puts
  breathing_exercise
  puts
  puts "Now, let's talk about your options for right now, before you start your work."
  puts "-= You can CHANGE your situation, environment or reactions."
  puts "-= You can ACCEPT that this is how you'll be feeling while you're working."
  puts "-= Or you can choose to try and LET GO of this feeling before you start your work."
  puts
  puts "What do you want to do right now? Type 'change', 'accept' or 'let go', or anything else to skip this."
  intervention = gets.chomp
  puts
  puts "Think for a minute about what prompted or triggered this feeling. Think for a minute. Type a quick note to yourself about it to remind you later if you'd like, or press enter when ready."
  trigger_note = gets.chomp
  puts
  case intervention.downcase
  when "change"
    puts "Think about your environment, your situation, or your reactions. You can change each of those, even in small ways."
    puts
    puts "Think for a minute about what you want to change, and what you'd need to make that change."

    pause_for(25)

    puts "You probably aren't going to make this change all at once right now. But let's jot down some next steps you want to take in the near future. We'll store those away for after you've finished your work."
    puts
    puts "When you're done listing things you want to do later, type 'done'."
    note_to_self = get_tasks
    puts
    puts "Now before we move on, let's make a small change to your situation right now. Here are some ideas:"
    puts "- Take a quick exercise break."
    puts "- Go for a walk around the block."
    puts "- Clean up a part of this room right now, or your desk."
    puts "- Grab a healthy snack, or drink a glass of water."
    puts
    puts "When you've done that, come back and hit 'enter' so we can start coding."
    gets.chomp
    puts
  when "accept"
    puts "Here are some things you might want to remind yourself about this trigger and your reaction to it:"
    puts "- It is as it is."
    puts "- I don’t have to agree with it or judge it as good or bad."
    puts "- I can always come back to this feeling later."
    puts "- I can keep my options open."
    puts "- This is a normal body reaction."
    puts "- I don’t have to fight it or try to stop it."
    puts "- It is as it is, but it won't stay that way. It will pass."
    puts
    puts "Jot down a thought about what accepting this means to you, so you can remember this later."
    note_to_self = gets.chomp
    puts

  when "let go"
    puts "Think about this trigger and your emotions from it. Ask yourself:"
    puts "- Is it worth it?"
    puts "- Is this something I can leave or let go of and move on from this experience?"
    puts "- Can I learn from this experience?"
    puts "- What would I want to do differently next time?"
    puts
    puts "Jot a note to yourself about this. Hit enter when done."
    note_to_self = gets.chomp
    puts
    puts "Now that you've logged how you're feeling and what might have caused it, think about how you don't have to hold onto that trigger anymore if you don't want to."
    puts
  else
    note_to_self = nil
  end
end

puts "Thanks for checking in with yourself!"
puts "If you want to see a log of your checkins, open this file again with the argument 'log'."
if note_to_self != nil
  puts "And to check the note you left yourself just now or in previous checkins, open this file with the argument 'pull'."
end

# store checkin to database
add_checkin(db, emotional_state, intensity, trigger_note, note_to_self)