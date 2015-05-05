# Front end
- Gulp can be installed by `npm install -g gulp` (requires sudo on Unix).
- It is recommended to install coffeescript through npm (`npm install -g coffee-script` - requires sudo on Unix). If you are using debian, the PPAs will probably have an old version of coffeescript. In particular, the behaviour of lines that start with a period has changed between verions of coffeescript

# Back end
- This requires ruby 2.0. If you are using debian, this may require a third-party PPA. The package name is usually `ruby2.0`. Use `sudo update-alternatives --config ruby` to change the ruby version that `/usr/bin/ruby` points to in debian.
- Do `sudo gem install bundle` to install bundle (which installs ruby dependencies as described by Gemfile and Gemfile.lock)
- Do `bundle install` to install the dependencies of the Gemfile of the current project. These may fail to install if you don't have ruby 2.x.
