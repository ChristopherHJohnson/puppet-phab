class phabricator::extender (
    $phabricator_path = '/usr/local/src/phabricator',
    $libphutil_path = '/usr/local/src/libphutil',
    $arcanist_path = '/usr/local/src/arcanist',
) {
    include 'git'

    Anchor['phabricator::begin'] ->
    class { 'arcanist':
        libphutil_path => $libphutil_path,
        arcanist_path => $arcanist_path,
    } ->
    Anchor['phabricator::end']

    # Ubuntu disables pcntl_* functions in php.ini, but phabricator's daemons need them.
    exec { "/bin/sed '/^disable_functions = pcntl/d' -i.orig /etc/php5/cli/php.ini":
        creates => '/etc/php5/cli/php.ini.orig',
        require => Package['php5-cli'],
        before => Class['::phabricator::daemons'],
    }

    vcsrepo { $phabricator_path:
        ensure => 'present',
        provider => 'git',
        source => 'git://github.com/facebook/phabricator.git',
    }

    # Create the database for Phabricator.
    $storage_bin = "${phabricator_path}/bin/storage"

    exec { 'install phabricator database':
        command => shellquote($storage_bin, 'upgrade', '-f'),
        unless => shellquote($storage_bin, 'status'),
        subscribe => Vcsrepo[$phabricator_path],
    }
}
