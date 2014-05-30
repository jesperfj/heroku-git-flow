class Heroku::Command::Base
  def app
    @app ||= if options[:confirm].is_a?(String)
      if options[:app] && (options[:app] != options[:confirm])
        error("Mismatch between --app and --confirm")
      end
      options[:confirm]
    elsif options[:app].is_a?(String)
      options[:app]
    elsif ENV.has_key?('HEROKU_APP')
      ENV['HEROKU_APP']
    elsif app_from_dir = extract_app_in_dir(Dir.pwd)
      app_from_dir
    else
      branch = git("symbolic-ref --short -q HEAD")
      app = git("config --get branch.#{branch}.heroku")
      unless app =~ /error/ || app.length==0
        app
      else
        # raise instead of using error command to enable rescuing when app is optional
        raise Heroku::Command::CommandFailed.new("No app specified.\nRun this command from an app folder or specify which app to use with --app APP.") unless options[:ignore_no_app]
      end
    end
  end
end