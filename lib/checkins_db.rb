class CheckinsDB
  def initialize(db)
    @db = db
    @db.execute_batch(create_tables_cmd)
    # Check if the emotions and states tables have been populated, and, if not, do so.
    unless @db.execute("SELECT name FROM emotions;").any? { |row| row[0] == "joy" }
      @db.execute_batch(populate_emotional_states_cmd)
    end
  end

  def create_tables_cmd
    # SQL command to make the tables if they don't exist.
    return <<-SQL
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
  end
  def populate_emotional_states_cmd
    return <<-SQL
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
  end

  # Add a checkin to the database
  def add(checkin_entry)
    # replace emotion name with matching id
    emotion_id = lookup_emotion_id(checkin_entry[:emotion])
    checkin_entry[:emotion] = emotion_id

    # replace state name with matching id, if exists
    if checkin_entry[:state]
      state_id = lookup_state_id(checkin_entry[:state])
      checkin_entry[:state] = state_id
    end

    # turn note to self into blob, if exists
    if checkin_entry[:note]
      checkin_entry[:note] = checkin_entry[:note].to_blob
    end

    @db.execute("INSERT INTO checkins (time, emotionID, stateID, intensity, trigger, noteToSelf) VALUES (?, ?, ?, ?, ?, ?)", checkin_entry[:time], checkin_entry[:emotion], checkin_entry[:state], checkin_entry[:intensity], checkin_entry[:trigger], checkin_entry[:note])
  end

  # look up the emotion ID in this DB for a given emotion name
  def lookup_emotion_id(emotion)
    emotion_id = @db.get_first_value("SELECT id FROM emotions WHERE name = ?", emotion)
  end

  # look up the state ID in this DB for a given state name
  def lookup_state_id(state)
    state_id = @db.get_first_value("SELECT id FROM states WHERE name = ?", state)
  end

  # generate SQL query that can pull the log, replace the ids from each table with the emotion/state names, etc
  def log(limit)
    qry_checkins_cmd = <<-SQL
      SELECT time, emotions.name, states.name, intensity
      FROM (checkins LEFT JOIN emotions ON checkins.emotionID = emotions.id) LEFT JOIN states
      ON checkins.stateID = states.id;
      SQL
    rows = @db.execute(qry_checkins_cmd)

    result = ""
    # make header row
    result += "Checkin time         | Emotion      | Emotional state  | Intensity \n"
    result += "---------------------|--------------|------------------|-----------\n"
    # initialize incrementer to test if going past limit
    i = 1

    # print that SQL query for each row, going back as long as incrementer is less than limit
    rows.reverse_each do |row|
      next if i > limit
      # turn all null or nil values and all numbers into strings
      row.map!(&:to_s)
      result += row[0].ljust(21) + "| " + row[1].ljust(13) + "| " + row[2].ljust(17) + "| " + row[3].ljust(9) + "\n"
      i += 1
    end
    return result
  end

  def review_notes
    # generate SQL queries that pull the times and all from the noteToSelf attribute, numbered
    pull_notes_cmd = <<-SQL
      SELECT time, emotions.name, states.name, trigger, noteToSelf
      FROM (checkins JOIN emotions ON checkins.emotionID = emotions.id) LEFT JOIN states
      ON checkins.stateID = states.id;
      SQL
    entries = @db.execute(pull_notes_cmd)
    result = ""

    entries.each do |entry|
      next unless entry[3] or entry[4]
      result += "Date and time: " + entry[0] + "\n"
      result += "Emotional state: " + entry[1]
      result += ", " + entry[2] if entry[2] # checking if state is nil
      result += "\n"
      result += "Trigger: " + entry[3] + "\n" if entry[3]
      result += "\n"
      result += "Note to self: \n\n" + entry[4] + "\n" if entry[4]
      result += "\n"
      result += " -=- -=- -=- -=- -=- -=- -=- -=- \n"
      result += "\n"
    end
    return result
  end

end