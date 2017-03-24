class Checkin
  def initialize
    el = EmotionList.new()

    @time = Time.now.strftime("%Y-%m-%d %H:%M:%S")

    observe_feeling
    @emotional_state = describe_feeling(el)
    @intensity = describe_feeling_instensity
    if @intensity > 5 and @emotional_state[:emotion] != "joy"
      @intervention = choose_intervention
      @trigger = describe_trigger
      case @intervention
      when "change"
        @note = change_self
      when "accept"
        @note = accept_self
      when "let go"
        @note = let_go_self
      else
        @note = nil
      end
    end
    close_checkin
  end

  def observe_feeling
    puts
    puts "OBSERVE how you're feeling."
    puts "No need to judge it, let's just pause and notice it."
    pause_for(25)
  end

  def describe_feeling(el)
    puts "DESCRIBE how you're feeling. Which of these emotions would you say it falls under?"
    puts
    puts "anger -=- joy -=- sadness -=- hurt -=- fear"
    puts
    puts "Type 'more' for a list of more words to help you figure out what you're feeling and how we'll categorize it."
    return categorize_feeling(STDIN.gets.chomp, el)
  end

  def describe_feeling_instensity
    puts
    puts "How strong is that feeling on a scale of 0 to 10?"
    intensity = STDIN.gets.chomp.to_i
    return 0 if intensity < 0
    return 10 if intensity > 10
    return intensity
  end

  # Give choice of possible interventions due to high negative emotions
  def choose_intervention
    puts
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
    return STDIN.gets.chomp.downcase
  end

  def describe_trigger
    puts
    puts "Think for a minute about what prompted or triggered this feeling. Think for a minute. Type a quick note to yourself about it to remind you later if you'd like, or press enter when ready."
    return STDIN.gets.chomp
  end

  def change_self
    puts "Think about your environment, your situation, or your reactions. You can change each of those, even in small ways."
    puts
    puts "Think for a minute about what you want to change, and what you'd need to make that change."
    pause_for(25)
    puts "You probably aren't going to make this change all at once right now. But let's jot down some next steps you want to take in the near future. We'll store those away for after you've finished your work."
    puts
    puts "When you're done listing things you want to do later, type 'done'."
    tasks = get_tasks
    puts
    puts "Now before we move on, let's make a small change to your situation right now. Here are some ideas:"
    puts "- Take a quick exercise break."
    puts "- Go for a walk around the block."
    puts "- Clean up a part of this room right now, or your desk."
    puts "- Grab a healthy snack, or drink a glass of water."
    puts
    puts "When you've done that, come back and hit 'enter' so we can start coding."
    STDIN.gets.chomp
    puts
    return tasks
  end

  def accept_self
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
    return STDIN.gets.chomp
  end

  def let_go_self
    puts "Think about this trigger and your emotions from it. Ask yourself:"
    puts "- Is it worth it?"
    puts "- Is this something I can leave or let go of and move on from this experience?"
    puts "- Can I learn from this experience?"
    puts "- What would I want to do differently next time?"
    puts
    puts "Jot a note to yourself about this. Hit enter when done."
    note_to_self = STDIN.gets.chomp
    puts
    puts "Now that you've logged how you're feeling and what might have caused it, think about how you don't have to hold onto that trigger anymore if you don't want to."
    puts
    return note_to_self
  end

  def close_checkin()
    puts "Thanks for checking in with yourself!"
    puts "If you want to see a log of your checkins, open this file again with the argument 'log'."
    if @note != nil
      puts "And to check the note you left yourself just now or in previous checkins, open this file with the argument 'pull'."
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

  # used to add some mindful wait time so user can observe emotions
  def pause_for(seconds)
    seconds.times { |s| print ((seconds - s).to_s + "... ") ; sleep 1 }
    puts
  end

  # used to put the feeling that the user feels into terms readable for our databases
  def categorize_feeling(feeling, emotion_list)
    if feeling.downcase == "more"
      puts
      puts emotion_list
      puts
      puts "Pick a word from the list above that describes how you're feeling right now."
      return categorize_feeling(STDIN.gets.chomp, emotion_list)
    elsif emotion_list.list.keys.include?(feeling.downcase)
      # emotion named by user, but not a secondary state
      categorized = { emotion: feeling.downcase, state: nil }
    else
      matching_emotion = emotion_list.list.select {|emotion, states| states.include? feeling.downcase}
      categorized = { emotion: matching_emotion.keys[0], state: feeling.downcase }
    end
    return categorized if defined? categorized
    # User gave invalid input, run again
    return categorize_feeling("more", emotion_list)
  end

  # Read in list of tasks that the user wants to remember for later.
  def get_tasks
    note_to_self = ""
    task = STDIN.gets.chomp
    until task.downcase == "done"
      note_to_self += " o " + task + "\n"
      task = STDIN.gets.chomp
    end
    return note_to_self.chomp
  end

  # Display checkin as a hash
  def to_h
    return {
      time: @time,
      emotion: @emotional_state[:emotion],
      state: @emotional_state[:state],
      intensity: @intensity ||= nil,
      trigger: @trigger ||= nil,
      note: @note ||= nil
    }
  end
end