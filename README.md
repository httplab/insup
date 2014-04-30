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
* **ignore** section specifies an array of patterns that are used to ignore files. Files that match ignore patterns will be neither tracked nor uploaded. The patterns must be specified in GIT ignore format relative to the working directory.
* **tracker** section specifies the tracker to use as well as its configuration. The tracker class is specified by the `class` option.
* **uploader** section specifies the uploader to use as well as its configuration. The uploader class is specified by the `class` option.
* **insales** secion holds information for connecting to Insales shop. To use insales features you should specify `subdomain`, `api_key` and `password` parameters.
