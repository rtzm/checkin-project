Gem::Specification.new do |s|
  s.name        = 'checkin_self'
  s.version     = '0.2.3'
  s.date        = '2017-04-05'
  s.summary     = 'checkin_self'
  s.description = 'A tool to integrate mindful checkins into your git workflow'
  s.authors     = ['Simon Swartzman']
  s.email       = 'simon.swartzman@gmail.com'
  s.files       = ["lib/checkin_self.rb", "lib/emotion_list.rb", "lib/checkin.rb", "lib/checkins_db.rb", "lib/githooker.rb", "README.md"]
  s.homepage    =
    'https://github.com/rtzm/checkin-project'
  s.add_runtime_dependency 'sqlite3'
  s.license       = 'MIT'
  s.executables   = ['checkin_self']
end
