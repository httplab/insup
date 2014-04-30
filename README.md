# insup

[![Build Status](https://travis-ci.org/httplab/insup.svg?branch=master)](https://travis-ci.org/httplab/insup)
[![Gem Version](https://badge.fury.io/rb/insup.svg)](http://badge.fury.io/rb/insup)
[![Coverage Status](https://coveralls.io/repos/httplab/insup/badge.png)](https://coveralls.io/r/httplab/insup)
[![Code Climate](https://codeclimate.com/github/httplab/insup.png)](https://codeclimate.com/github/httplab/insup)
[![Dependency Status](https://gemnasium.com/httplab/insup.svg)](https://gemnasiurm.com/httplab/insup)

## Description

Insup Insales theme uploader.

## Installation

```bash
gem install insup
```

## Usage

### Preparing

Enter the directory you want to sync with the remote service. Then type `insup init` to initialize your working directory with **.insup** file that holds all neccessary Insup configuration.

Open **.insup** file with your favourite text editor and modify the configuration according to your needs.

### Configuration
**.insup** file is a YAML file. Here's a list of the configuration options.

* **track** section is an array of directories which you want to track for changes. Specify locations relative to the working directory
* **ignore** section specifies an array of patterns that are used to ignore files. Files that match ignore patterns will be neither tracked nor uploaded. The patterns must be specified in Git ignore format relative to the working directory.
* **tracker** section specifies the tracker to use as well as its configuration. The tracker class is specified by the `class` option.
* **uploader** section specifies the uploader to use as well as its configuration. The uploader class is specified by the `class` option.
* **insales** secion holds information for connecting to Insales shop. To use insales features you should specify `subdomain`, `api_key` and `password` parameters.

#### Trackers

Currently there are two trackers available:

* **Git tracker** finds changes in the working directory using Git index. This tracker will operate only if the working dir is a Git repository. Select this tracker by specifying `Insup::Tracker::GitTracker` or `git` in the `class` section of the tracker configuration.
* **Simple tracker** will always consider all files in the working directory modified (except the ignored ones). Specify `Insup::Tracker::SimpleTracker` or `simple` ins the `class` section.

#### Uploaders

Currently there are two uploaders available:

* **Insales uploader** will upload files to the specified Insales theme. Specify `Insup::Uploader::Insales` or `insales` in the `class` section of the uploader configuration. Insales uploader also requires `theme_id` to be specified. Working directory should include 3 subfolders *media*, *snippets* and *templates*. The same 3 folders should be specified in the `track` sectio of .insup file.

* **Dummy uploader** will only print its operations to the console without actually uploading anything. It can be used for testing the configuration. Use by specifying `dummy` or `Insup::Uploader::Dummy` in the `class` section.

### Operation modes

#### Listen mode

In this mode Insup will continuously listen to the changes in tracked locations and upload the changes immidiately. It will use the specified uploader, but the tracker is ignores. Listen mode will only watch files that do not match ignore patterns.

Activate listen mode by typing
```bash
insup listen
```
in your working directory.


#### Track mode

In this mode you can periodically check for changes and upload changed files to the remote storage. Tracker specified in the .insup file is used to detect changes.

Print working directory status accroding to the selected tracker
```bash
insup status
```

Upload changes
```bash
insup commit [file1 [file2 [file3 [...]]]]
```
Call `commit` command with the file list to upload only files specified.

### Other commands

List all themes in the Insales shop if `insales` section is given in the .insup file:
```bash
insup insales list-themes
```

List files under tracked locations:
```bash
insup list-files [--all|--ignored]
```
Use `--all` option to list *all* files, and `--ignored` to list only ignored files. Calling this command without options will result in a list of tracked files only.
