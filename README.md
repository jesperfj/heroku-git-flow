# Multi-branch Heroku Deploys

This Heroku CLI plugin helps you manage Heroku deployments from multiple branches in your local git repo.

It uses the new build API to deploy and does not depend on `git push`, SSH keys, etc. Therefore, it might be interesting to you if you cannot or don't want to deploy your Heroku apps using the normal `git push heroku master` work flow.

Assumptions:

* You're using git for version control
* You have a [Heroku account][1] and have installed [Heroku Toolbelt][2]
* You're executing the plugin commands from a git configured directory.

[1]: https://signup.heroku.com
[2]: https://toolbelt.heroku.com/

# Install

    heroku plugins:install https://github.com/jesperfj/heroku-git-flow.git

# Usage

## Bootstrapping from sample code

Nobody writes code from scratch anymore. When you decide to try out a new, promising framework or library, it comes with sample code that you can copy and run to get off the ground quickly. From there you will make the code your own, but it's a huge time saver to get some help with the basics.

When you've found a great sample app on Github which includes an app.json file you can bootstrap your own Heroku app from the sample in a few simple steps:

### Fork the app

Github makes this easy. For example, go ahead and [fork jesperfj/node-todo](https://github.com/jesperfj/node-todo/fork) (which is itself a fork of [scotch-io/node-todo](https://github.com/scotch-io/node-todo))

### Clone locally

Now clone the code down to your personal development environment with:

    $ git clone git@github.com:roanak/node-todo.git

(replace roanak with your own Github username).

### Set up app on Heroku

Thanks to app.json and Heroku's new setup service, you can bootstrap the app on Heroku as simple as:

    $ heroku setup
    Uploading source tarball for branch master... done
    Setting up new Heroku app for branch master........ done
    Branch master now deploys to powerful-retreat-3783

<!--It's optional (but recommended) to provide an app name when you run setup on the master branch. This establishes and meaningful project name on Heroku. If you don't provide one, your app will get a haiku name like boiling-mesa-6179. -->

In less than a minute you went from discovering a new interesting sample app to running it in your own dev environment, ready for hacking!

### Deploy a change

Sample apps are no fun if you can't edit them and make'em your own. Fortunately it's easy to deploy a change to your new app:

1. Make some edits
2. `git add` and `git commit`
3. `heroku deploy`

It'll look something like this:

    [make some edits]
    $ git add .
    $ git commit -m "edits"
    [master c217eb3] edits
     1 file changed, 1 insertion(+), 1 deletion(-)
    $ heroku deploy
    Uploading source tarball for branch master... done
    Deploying branch master (commit c217eb3457) to powerful-retreat-3783.... done

    -----> Node.js app detected
    -----> Requested node range:  0.10.x
    -----> Resolved node version: 0.10.28
    -----> Downloading and installing node
    -----> Restoring node_modules directory from cache
    -----> Pruning cached dependencies not specified in package.json
    -----> Writing a custom .npmrc to circumvent npm bugs
    -----> Exporting config vars to environment
    -----> Installing dependencies
    -----> Caching node_modules directory for future builds
    -----> Cleaning up node-gyp and npm artifacts
    -----> No Procfile found; Adding npm start to new Procfile
    -----> Building runtime environment
    -----> Discovering process types
           Procfile declares types -> web

    -----> Compressing... done, 9.3MB
    -----> Launching... done, v5
           http://powerful-retreat-3783.herokuapp.com/ deployed to Heroku

    Commit c217eb3457 on branch master now running on powerful-retreat-3783


## Team development with branch deployments

Team development processes vary from place to place. This plugin is designed for a particular process used for web app development by many organizations and [documented by Github back in 2011](http://scottchacon.com/2011/08/31/github-flow.html):

* Anything in the master branch is deployable
* To work on something new, create a descriptively named branch off of master (ie: new-oauth2-scopes)
* Commit to that branch locally and regularly push your work to the same named branch on the server
* When you need feedback or help, or you think the branch is ready for merging, open a pull request
* After someone else has reviewed and signed off on the feature, you can merge it into master
* Once it is merged and pushed to ‘master’, you can and should deploy immediately

(I don't claim that Github invented it. But they've been a champion for this style of development and we use it too at Heroku).

You just got your project off the ground and now it's time to write code.

### Set up topic branch with its own Heroku app

Create local branch:

    $ git checkout -b new-feature
    Switched to a new branch 'new-feature'

Write some code, then commit and push branch to origin

    $ git add .
    $ git commit -m "fix"
    [new-feature d801f95] fix
     1 file changed, 1 insertion(+), 1 deletion(-)

Set up a Heroku app for this topic branch:

    $ heroku setup
    Uploading source tarball for branch new-feature... done
    Setting up new Heroku app for branch new-feature.......... done
    Branch new-feature now deploys to mighty-garden-7523

That's it. You have your very own Heroku deployment for this topic branch. Check it out:

    $ heroku open -a mighty-garden-7523

You can see how your branches are targeted to different Heroku apps with:

    $ heroku target
    master -> powerful-retreat-3783
    new-feature -> mighty-garden-7523

### Deploying new code from the topic branch

The `setup` command performs first time setup, creating the app and provisioning add-ons, etc. For deploying new changes, use the `deploy` command. For example, if you've made some code edits, you follow the standard git workflo:

    $ git add .
    $ git commit -m "more edits"
    [new-feature ab821a2] more edits
     1 file changed, 1 insertion(+), 1 deletion(-)

Then deploy:

    $ heroku deploy
    Uploading source tarball for branch new-feature... done
    Deploying branch new-feature (commit ab821a2298) to mighty-garden-7523.... done

    -----> Node.js app detected
    -----> Requested node range:  0.10.x
    -----> Resolved node version: 0.10.28
    -----> Downloading and installing node
    -----> Restoring node_modules directory from cache
    -----> Pruning cached dependencies not specified in package.json
    -----> Writing a custom .npmrc to circumvent npm bugs
    -----> Exporting config vars to environment
    -----> Installing dependencies
    -----> Caching node_modules directory for future builds
    -----> Cleaning up node-gyp and npm artifacts
    -----> No Procfile found; Adding npm start to new Procfile
    -----> Building runtime environment
    -----> Discovering process types
           Procfile declares types -> web

    -----> Compressing... done, 9.3MB
    -----> Launching... done, v5
           http://mighty-garden-7523.herokuapp.com/ deployed to Heroku

    Commit ab821a2298 on branch new-feature now running on mighty-garden-7523

### Things to ponder

As stated, deployment processes vary wildly. There are several separate goals to optimize for: fidelity, agility, collaboration, etc. You may want to hack on this plugin yourself to improve it further or to optimize for certain goals. For example:

#### Deploy non-committed code

Currently the tarball is created by git from checked in code. That means you have to commit your code before you deploy. Sometimes you may want to deploy before you commit if you're doing highly experimental stuff and you're deploying to a personal, throw-away app anyways. 

I'll argue it's a small cost to commit first because you should be on a topic branch and you can squash commits before merging. But I can see some might want to skip the step. In particular, if you are not using git, you will need to make some changes. Note that you'll need to vendor a Ruby tar library into your plugin if you choose to tar up files on your own. You'll also need to invent a suitable version string, e.g. a manually calculated SHA checksum over your tarball.

#### Deploy from your central repository instead of from local

When you deploy, the tarball is built locally from the code on your machine. This introduces the risk that you may be deploying a version of the app with noone else having access to the source code (if you forget to push it). As long as you push your code, there should be no other concerns: the commit hash will uniquely identify the deployed version whether it came from your local machine or from your central repo service. But see next point for more thoughts.

#### The build and deploy process is not centrally defined

In this current implementation, every developer is responsible for setting up branch mappings to production, staging and topic deployments. I can choose to map staging branch to one app while my colleague choose to map it to another app. If I join a new team, there's no brain-dead-simple way for me to get set up with the right mappings. Two changes will move you in a more team-high-fidelity direction:

* Always deploy branches stored in your central repo. That way, you're only deploying stuff that everyone else can see. This comes with some slight inconvenience but feels right for serious production environments.
* Store branch mappings centrally. It's not too hard to build a service that manages branch mappings for you, but you will have to answer design questions around permissions which can get a bit tricky since you have two permission systems in play: your central repo service and Heroku.


<!--
## Viewing past build outputs

The build status and output for each build can be viewed later. Get a list of past builds with:

    $ hk show-build
    Builds on roanak-todo-new-feature:
    4358645d-4c75-2ef4-a6d0-41c460935dec  succeeded roanak@isfjeldet.io 2014-05-06T16:42:58+00:00
    8d1fdedd-1613-474e-2940-a2a10d4748c1  succeeded roanak@isfjeldet.io 2014-05-06T16:50:26+00:00

View a build with:

    $ hk show-build 8d1fdedd-1613-474e-2940-a2a10d4748c1
    App:        roanak-todo-new-feature
    Build id:   8d1fdedd-1613-474e-2940-a2a10d4748c1
    Created at: 2014-05-06T16:50:26+00:00
    Version:    b4086720968e0e64af27b4e27d6adbf9fe3854c5
    User:       roanak@isfjeldet.io
    Status:     succeeded
    Slug id:    213526f5-1037-45d7-9bff-cb90ffed2482
    Build output:

    [build output like above]

-->
