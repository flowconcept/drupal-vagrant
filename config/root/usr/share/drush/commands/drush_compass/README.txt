/**
 * @file
 * Documentation for Drush include for integrating Compass
 * http://drupal.org/project/drush_compass 7.x-1.2
 * Posted by pobster http://drupal.org/user/25159
 * documentation author decibel.places http://drupal.org/user/58977
 * February 4, 2012
 */

Compass is an open-source CSS Authoring Framework which uses the Sass extension of CSS3, adding
nested rules, variables, mixins, selector inheritance, and more. It’s translated to well-formatted,
standard CSS and makes your stylesheets easier to organize and maintain.

This module provides a simple plugin to for compiling stylesheets with drush, it allows you to;

* Specify which themes you want to run an action on (or across all themes)
* Specify the environment switch for Compass
* Force a rebuild of stylesheets
* You can also use the --verbose switch if you wish to see the full command line output

Project sponsored by ITV.com. Initial source code written by Ben Scott.

=================

PREREQUISITES

This is a plugin for Drush (DRUpal SHell)
You cannot use it without installing Drush: http://drush.ws

Compass requires Ruby
Instructions for installing Ruby then Compass: http://compass-style.org/install/

=================

INSTALL

Download tarball into your drush/includes folder

This is NOT a Drupal module; do NOT put it in your modules directory!

Extract to drush/includes:

compass_actions (folder)
compass.drush.inc

(not necessary for function but good to keep around)
drush_compass.info (version number, date etc.)
LICENSE.txt (GNU GENERAL PUBLIC LICENSE Version 2, June 1991)

=================

PREPARE PROJECT

First create or init a Compass project in your theme

Create will generate a Compass project with pre-configured folders; may not be useful for existing projects using existing themes
$ drush create [theme_name]

// Drush Compass does not include a compass init function, used to initialize an existing project
// You can run Compass on the command line from the installation directory of Compass
$ compass init [path/to/theme]

Edit [path/to/theme]/config.rb

http_path = "/"
css_dir = "css"
sass_dir = "sass"
images_dir = "images"
javascripts_dir = "scripts"

Copy your CSS files to the sass_dir and rename them with the extension [style].scss
Compass will compile your SASS files into CSS in the css_dir
DO NOT ever edit the css files; all edits MUST be made to the SASS files

=================

USE

Syntax:
$ drush [command] [theme_name]

(Note: you don't have to give the path, Drush knows it from the theme machine name)

Commands:
* clean
* compile
* create
* init
* stats
* validate


 * clean
Remove generated files and the sass cache from a Compass theme
$ drush clean [theme_name]

 * compile
Compiles and validate the generated theme stylesheets
$ drush compile [theme_name]

 * create
Create a new compass project
$ drush create [theme_name]

 * init
Initialse a new compass project
$ drush init [project-type] [theme_name]

 * stats
Print out statistics about your stylesheets
$ drush stats [theme_name]

 * validate
Validate the generated CSS.
$ drush validate [theme_name]

=================

RESOURCES

Compass web site
http://compass-style.org
Compass command line
http://compass-style.org/help/tutorials/command-line/
Compass CSS3 imports
http://compass-style.org/reference/compass/css3/

SASS
http://sass-lang.com/

Latest version of this document on Github:
https://github.com/decibelplaces/drush_compass_docs/blob/master/README.txt

=================