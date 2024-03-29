# config valid only for current version of Capistrano
lock "~> 3.17.3"

set :department, 'ldpd'
set :instance, fetch(:department)
set :application, 'hours'
set :repo_name, "ldpd-hours"
set :deploy_name, "#{fetch(:application)}_#{fetch(:stage)}"
# used to run rake db:migrate, etc
# Default value for :rails_env is fetch(:stage)
set :rails_env, fetch(:deploy_name)
# use the rvm wrapper
set :rvm_custom_path, '~/.rvm-alma8'
set :rvm_ruby_version, fetch(:deploy_name)

set :repo_url,  "git@github.com:cul/#{fetch(:repo_name)}.git"

set :remote_user, "renserv"

# Default deploy_to directory is /var/www/:application
set :deploy_to,   "/opt/passenger/#{fetch(:deploy_name)}"

# Default value for :log_level is :debug
set :log_level, :info

# Default value for linked_dirs is []
set :linked_dirs, fetch(:linked_dirs, []).push('log')

# Default value for keep_releases is 5
set :keep_releases, 3

set :passenger_restart_with_touch, true

set :linked_files, fetch(:linked_files, []).push(
  "config/database.yml",
  "config/secrets.yml",
  "config/wifi_density.yml"
)

before "deploy:assets:precompile", "deploy:yarn_install"

namespace :deploy do
  desc "Report the environment"
  task :report do
    run_locally do
      puts "cap called with stage = \"#{fetch(:stage,'none')}\""
      puts "cap would deploy to = \"#{fetch(:deploy_to,'none')}\""
      puts "cap would install from #{fetch(:repo_url)}"
      puts "cap would install in Rails env #{fetch(:rails_env)}"
    end
  end

  desc "Add tag based on current version from VERSION file"
  task :auto_tag do
    current_version = "v#{IO.read("VERSION").strip}"

    ask(:tag, current_version)
    tag = fetch(:tag)

    system("git tag -a #{tag} -m 'auto-tagged' && git push origin --tags")
  end

  desc "Run rake yarn install"
  task :yarn_install do
    on roles(:web) do
      within release_path do
        execute("cd #{release_path} && yarn install --silent --no-progress --no-audit --no-optional")
      end
    end
  end
end
