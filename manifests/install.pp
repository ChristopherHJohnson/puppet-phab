# == Class: phabricator::install
#
# This module installs Phabricator dependencies.
#
# === Parameters
#
# === Variables
#
# === Examples
#
class phabricator::install {
  
  package { [
    'g++',
    'build-essential',
    'python-phabricator',
    'php5',
    'php5-mysql',
    'php5-gd',
    'php-apc',
    'php5-mailparse',
    'php5-dev',
    'php5-curl',
    'php5-cli',
    'php5-json',
    'ruby-msgpack',
    'ruby-selinux',
    'php5-ldap']:
        ensure => present;
  }
  
  git::install { 'phabricator/libphutil':
      directory => "${phabdir}/libphutil",
      git_tag   => $git_tag,
      lock_file => $lock_file,
      before    => Git::Install['phabricator/arcanist'],
      notify   => Exec['build_xhpast'],
  }

  git::install { 'phabricator/arcanist':
      directory => "${phabdir}/arcanist",
      git_tag   => $git_tag,
      lock_file => $lock_file,
      before    => Git::Install['phabricator/phabricator'],
  }

  git::install { 'phabricator/phabricator':
      directory => "${phabdir}/phabricator",
      git_tag   => $git_tag,
      lock_file => $lock_file,
      notify    => Exec["ensure_lock_${lock_file}"],
  } 
 
  exec { 'build_xhpast':
    command   => "${phabricator::config::base_dir}/libphutil/scripts/build_xhpast.sh",
    logoutput => true,
    subscribe => Vcsrepo["${phabricator::config::base_dir}/libphutil"],
    require   => [
      Package['g++'],
      Package['build-essential'],
    ]
  }
}
