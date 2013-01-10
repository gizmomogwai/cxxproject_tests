
def projects
  Dir.new('..').entries.delete_if{|i|i.index('.')}.sort.inject({}) do |memo,p|
    stages = []
    stages << :SPEC if File.directory?("../#{p}/spec")
    stages << :ACCEPT if File.directory?("../#{p}/accept") 
    memo[p] = stages
    memo
  end
end

desc 'showd an project overview'
task :overview do
  sh 'gem install terminal-table'
  require 'terminal-table'
  rows = []
  projects.each do |p,v|
    rows << [p, v.include?(:SPEC) ? '*' : ' ', v.include?(:ACCEPT) ? '*' : ' ']
  end
  table = Terminal::Table.new(:title => 'Project Overview', :headings => ['Project', 'Unit-Tests', 'Acceptance-Tests'], :rows => rows, :style => {:width => 80})
  puts table
end

desc 'test all projects'
task :test_all => [:overview] do
  projects.each do |p,v|
    if v.include?(:SPEC) || v.include?(:ACCEPT)
      puts "-" * 80
      puts "- working on '#{p}' in '#{File.absolute_path(File.join(Dir.pwd, '..', p))}'"
      puts "-" * 80
      cd "../#{p}" do
        sh 'rvm --force gemset empty'
        sh 'gem install rspec bundler builder grit'
        sh 'rake spec' if v.include?(:SPEC)
        sh 'rake prepare_accept accept' if v.include?(:ACCEPT)
      end
    end
  end
end

task :default => :test_all
