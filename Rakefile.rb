def projects
  s = [:SPEC]
  a = [:ACCEPT]
  sa = s + a
  {'cxxproject' => sa, 'cxx' => sa, 'cxxproject_tomake' => sa}
end

desc 'test all projects'
task :test_all do
  projects.each do |p,v|
    cd "../#{p}" do
      sh 'rvm --force gemset empty'
      sh 'gem install rspec bundler builder grit'
      sh 'rake spec' if v.include?(:SPEC)
      sh 'rake prepare_accept accept' if v.include?(:ACCEPT)
    end
  end
end

task :default => :test_all
