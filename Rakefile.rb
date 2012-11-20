def projects
  ['cxxproject', 'cxx', 'cxxproject_tomake']
end

desc 'test all projects'
task :test_all do
  projects.each do |p|
    cd "../#{p}" do
      sh 'rvm --force gemset empty'
      sh 'gem install rspec'
      sh 'rake prepare_accept accept'
    end
  end
end

task :default => :test_all
