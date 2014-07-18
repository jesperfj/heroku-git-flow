$stdout.sync = true
require 'tempfile'
require 'excon'

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
    file = Tempfile.new('heroku')
    begin
      git("archive #{branch} --format tar.gz -o #{file.path}.tar.gz")
      size = (File.size(file.path+'.tar.gz').to_f/1000000).round(1)
      version = git("rev-parse #{branch}")
      print("Uploading source tarball (#{size} MB) for branch #{branch}...")
      drop = Heroku::HDrop::DropFile.new
      drop.upload(file.path+'.tar.gz')
      puts(" done")

      print "Deploying branch #{branch} (commit #{version[0..9]}) to #{app}."
      build = api.start_build(drop.get, app, version)

      if ENV['STREAMING_BUILD_RESULT']
        streaming_build_output(build,version,branch,app)
      else
        nonstreaming_build_output(build,version,branch,app)
      end
    ensure
      file.close
      file.unlink
    end
  end

  private

    def streaming_build_output(build, version, branch, app)
      puts
      streamer = lambda do |chunk, remaining_bytes, total_bytes|
        puts chunk
      end

      res = Excon.get(build['output_stream_url'],
        response_block: streamer
      )

      build_result = api.build_result(app, build['id'])
      # build should be done but checking just in case
      while(build_result['build']['status'] == 'pending')
        sleep(3)
        build_result = api.build_result(app, build_result['build']['id'])
      end

      if build_result['build']['status'] == 'succeeded'
        puts "Build successful."
        puts
        puts "Commit #{version[0..9]} on branch #{branch} now running on #{app}"
        puts
      else
        puts "Build failed!"
        puts build_result['failure_message']
      end
    end

    def nonstreaming_build_output(build, version, branch, app)
      build_result = api.build_result(app, build['id'])
      while(build_result['build']['status'] == 'pending')
        print('.')
        sleep(3)
        build_result = api.build_result(app, build_result['build']['id'])
      end
      if build_result['build']['status'] == 'succeeded'
        puts " done"
        build_result['lines'].each { |line|
          print line['line']
        }
        puts "Commit #{version[0..9]} on branch #{branch} now running on #{app}"
        puts
      else
        puts " failed"
        puts build_result['failure_message']
      end

    end


end
