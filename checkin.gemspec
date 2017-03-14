Gem::Specification.new do |s|
  s.name        = 'checkin-self'
  s.version     = '0.0.2'
  s.date        = '2017-03-13'
  s.summary     = "checkin"
  s.description = "A tool to integrate mindful checkins into your git workflow"
  s.authors     = ["Simon Swartzman"]
  s.email       = 'simon.swartzman@gmail.com'
  s.files       = ["lib/checkin.rb", "lib/emotion_list.rb", "README.md"]
  s.homepage    =
    'https://github.com/rtzm/checkin-project'
  s.license       = 'MIT'
  s.executables   = ["checkin"]
end