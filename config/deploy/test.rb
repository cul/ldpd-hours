server 'ldpd-nginx-test1.cul.columbia.edu', user: fetch(:remote_user), roles: %w(app db web)
# Current branch is suggested by default in development
ask :branch, proc { `git tag --sort=version:refname`.split("\n").last }
