# == Class: phabricator::params
#
# This module manages the default Phabricator parameters.
#
# === Parameters
#
# [*base_dir*]
# [*environment*]
# [*user*]
# [*group*]
#
# === Variables
#
# === Examples
#
class phabricator::params {
  $base_dir    = '/srv/phab'
  $environment = 'production'
  $user        = 'phabricator'
  $group       = 'phabricator'
}
