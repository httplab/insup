### Installation:

1. Clone this GIT repository into local folder
2. Go to the cloned repository
3. Execute `bundle install --path vendor/bundle`
4. Go to the directory with your files
5. Execute `cp <path_to_rad_repo>/.rad.template .rad`
6. Modify .rad file in your directory


### Usage:

You should either add `<path_to_rad_repo>/bin` to your `$PATH` variable or execute `<path_to_rad_repo>/bin/rad <command>` each time.

There are currently following commands implemented:

* `rad config` --- print current configuration
* `rad list-files` --- list all tracked files according to the selected tracker
* `rad status` --- list all changes to be commited accroding to the selected tracker
* `rad commit` --- apply all changes to the remote storage



