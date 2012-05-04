Check your redmine account !
And change your password !

Go check the wiki on redmine !

About ruby projects:
The 'main' file(s) are in the base directory. The modules they use are in the lib/
directory.

Gems are little ruby packages. Mostly they are libs but they can sometimes be small
utilities (such as the 'bundler' gem)

There is a file called 'Gemfile' in the base directory. This is to be used with the gem
'bundler': if you want to install the gems required by the program, just type:
bundle install
before launching.

PLEASE don't use whatever ruby package you have in your distro. Seriously, REMOVE them.
The good way to install ruby is through 'rvm'.
The simplest way to install rvm is with:
$ curl https://raw.github.com/wayneeseguin/rvm/master/binscripts/rvm-installer | bash -s stable

Or just visit the rvm website (http://beginrescueend.com/) if you want another way.

If you use something other than bash as your shell, put this in your .$(your_shell)rc:
[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"

(checked on zsh)

Then install any ruby using 'rvm install $ruby_version'.
This project will use ruby 1.9, so try 'rvm install 1.9.3'.
Then use 'rvm use $ruby_version' to use a ruby version you've installed.


rvm comes with 'bundler' already, but if you don't have it, use 'gem install bundler'.
Then, when you have bundler, please always install gems using the Gemfile, and never
using 'gem install', this way everybody will be kept up to date.


ruby programmer's favorite text editor is Sublime Text 2 beta. I personally still often
use emacs but I try to use Sublime Text, which is awesome.
