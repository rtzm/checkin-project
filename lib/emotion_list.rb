class EmotionList
  attr_reader :list
  def initialize
    @list = {
      "anger" => [
        "bothered",
        "annoyed",
        "bitter",
        "angry",
        "irritated",
        "disgusted",
        "frustrated",
        "exasperated",
        "furious"
      ],
      "joy" => [
        "content",
        "peaceful",
        "relaxed",
        "cheerful",
        "satisfied",
        "joyous",
        "excited",
        "ecstatic",
        "happy"
        ],
      "sadness" => [
        "sad",
        "depressed",
        "distraught",
        "despair",
        "melancholy",
        "grief",
        "helpless",
        "hopeless",
        "miserable"
        ],
      "hurt" => [
        "lonely",
        "homesick",
        "abandoned",
        "embarrassed",
        "shame",
        "guilt",
        "foolish",
        "humiliated"
        ],
      "fear" => [
        "uncertain",
        "worried",
        "anxious",
        "frightened",
        "scared",
        "nervous",
        "afraid",
        "terrified",
        "overwhelmed"
        ]
      }
  end
  def to_s
    result = ""
    @list.each do |emotion, states|
      result += emotion.upcase + ":\n"
      result += "   " + states.join(", ")
      result += "\n"
    end
    return result
  end
end