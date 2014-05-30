$stdout.sync = true
require 'tempfile'

class Heroku::Command::Deploy < Heroku::Command::Base


  # deploy
  #
  # deploy a branch to its targeted Heroku app
  #
  def index
    branch = git("symbolic-ref --short -q HEAD")
    app = git("config --get branch.#{branch}.heroku")
    unless app
      error("Branch #{branch} does not target a Heroku app.\nUse heroku target:set to set a target app\nor use heroku setup to set up new app.")      
    end
    file = Tempfile.new('hdrop')
    begin
      git("archive #{branch} --format tar.gz -o #{file.path}.tar.gz")
      version = git("rev-parse #{branch}")
      print("Uploading source tarball for branch #{branch}...")
      drop = Heroku::HDrop::DropFile.new
      drop.upload(file.path+'.tar.gz')
      puts(" done")
      print "Deploying branch #{branch} (commit #{version[0..9]}) to #{app}."
      build = api.start_build(drop.get, app, version)
      build = api.build_result(app, build['id'])
      while(build['build']['status'] == 'pending')
        print('.')
        sleep(3)
        build = api.build_result(app, build['build']['id'])
      end
      if build['build']['status'] == 'succeeded'
        puts " done"
        build['lines'].each { |line|
          print line['line']
        }
        puts "Commit #{version[0..9]} on branch #{branch} now running on #{app}"
        puts
      else
        puts " failed"
        puts build['failure_message']
      end
    ensure
      file.close
      file.unlink
    end
  end

end
