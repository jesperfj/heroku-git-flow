class Heroku::Command::Target < Heroku::Command::Base

  # target
  #
  # list all targets
  #
  def index
    git("config --get-regexp branch\\..*\\.heroku").split("\n").each { |t|
      cols = t.split
      puts "    #{cols[0].split('.')[1]} -> #{cols[1]}"
    }
  end

  # target:set
  #
  # target branch in local repo to Heroku app
  #
  def set
    unless app
      error("No app specified.\nSpecify which app to target with --app APP.")
    end
    unless args[0]
      error("No branch specified.\nUsage: heroku target:set BRANCH --app APP")
    end
    git("config branch."+args[0]+".heroku "+app)
  end

  # target:remove
  #
  # remove branch target
  #
  def remove
    unless args[0]
      error("No branch specified.\nUsage: heroku target:remove BRANCH")
    end
    git("config --unset branch.#{args[0]}.heroku")
  end

  # target:get
  #
  # show targeted Heroku app for a branch
  #
  def get
    unless args[0]
      error("No branch specified.\nUsage: heroku target:get BRANCH")
    end
    git("config --get branch."+args[0]+".heroku")
  end

end
