
def quiet_cd(dir)
  cd(dir, :verbose => false) do
    yield
  end
end

def has_git(dir)
  return File.exists?(File.join(dir, '.git'))
end

def has_github(dir)
  res = false
  begin
    quiet_cd dir do
      s = `git remote`
      res = s.index('github') != nil
    end
  rescue => e
    res = false
  end
  res
end

def projects
  Dir.new('..').entries.delete_if{|i|i.index('.')}.sort.inject({}) do |memo,p|
    stages = []
    stages << :SPEC if File.directory?("../#{p}/spec")
    stages << :ACCEPT if File.directory?("../#{p}/accept")
    stages << :GITHUB if has_github("../#{p}")
    stages << :GIT if has_git("../#{p}")
    memo[p] = stages
    memo
  end
end

desc 'showd an project overview'
task :overview do
  sh 'gem install terminal-table'
  
  require 'terminal-table'
  rows = []
  projects.each do |p,tests|
    rows << [p, tests.include?(:SPEC) ? '*' : ' ', tests.include?(:ACCEPT) ? '*' : ' ', tests.include?(:GIT) ? '*' : ' ', tests.include?(:GITHUB) ? '*' : ' ']
  end
  table = Terminal::Table.new(:title => 'Project Overview', :headings => ['Project', 'Unit-Tests', 'Acceptance-Tests', 'Git', 'Github'], :rows => rows, :style => {:width => 80})
  puts table
end

desc 'test all projects'
task :test_all => [:overview] do
  projects.each do |p,tests|
    if tests.include?(:SPEC) || tests.include?(:ACCEPT)
      puts "-" * 80
      puts "- working on '#{p}' in '#{File.absolute_path(File.join(Dir.pwd, '..', p))}'"
      puts "-" * 80
      quiet_cd "../#{p}" do
        sh 'rvm --force gemset empty'
        sh 'gem install rspec bundler builder grit'
        sh 'rake spec' if tests.include?(:SPEC)
        sh 'rake prepare_accept accept' if tests.include?(:ACCEPT)
      end
    end
  end
end

def projects_with_configured_github
  projects.keys.select {|p|has_github("../#{p}")}
end

desc "upload #{projects_with_configured_github.join(', ')} to github default:master"
task :to_github do
  projects_with_configured_github.each do |p|
    puts "pushing on #{p}"
    begin
      quiet_cd "../#{p}" do
        sh 'git push github default:master'
      end
    rescue
      puts "no github repository defined for #{p}"
    end
  end
end

task :default => :test_all
