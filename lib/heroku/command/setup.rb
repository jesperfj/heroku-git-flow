$stdout.sync = true
require 'tempfile'

class Heroku::Command::Setup < Heroku::Command::Base

  # setup
  #
  # set up a new app deployment for a branch
  #
  def index
    file = Tempfile.new('hdrop')
    begin
      branch = git("symbolic-ref --short -q HEAD")
      git("archive #{branch} --format tar.gz -o #{file.path}.tar.gz")
      # pro-tip: you can get commit hash from tarball with git("get-tar-commit-id #{file.path}.tar.gz")
      print("Uploading tarball for #{branch} branch...")
      drop = Heroku::HDrop::DropFile.new
      drop.upload(file.path+'.tar.gz')
      puts(" done")
      print "Setting up new Heroku app for branch #{branch}"
      setup = api.start_setup(drop.get)
      while(setup['status'] == 'pending')
        print('.')
        sleep(3)
        setup = api.setup_result(setup['id'])
      end
      if setup['status'] == 'succeeded'
        puts " done"
        puts "Branch #{branch} now deploys to #{setup['app']['name']}"
        git("config branch.#{branch}.heroku #{setup['app']['name']}")
      else
        puts " failed"
        puts setup['failure_message']
      end
    ensure
      file.close
      file.unlink
    end
  end

end
