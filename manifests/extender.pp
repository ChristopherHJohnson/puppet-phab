class phabricator::extender (
    $libext_tag = '',
    $extension_tag = '',
) {
    include 'git'

    if ($libext_tag) {
    
        file { '/srv/phab/libext':
            ensure => 'directory',
        }
        
        $libext_lock_path = "${phabdir}/library_lock_${libext_tag}"
    
        git::install { 'phabricator/extensions/Sprint':
            directory => "${phabdir}/libext/Sprint",
            git_tag   => $libext_tag,
            lock_file => $libext_lock_path,
            notify    => Exec[$libext_lock_path],
            before    => Git::Install['phabricator/phabricator'],
        }
        
        exec {$libext_lock_path:
            command => "touch ${libext_lock_path}",
            unless  => "test -z ${libext_lock_path} || test -e ${libext_lock_path}",
            path    => '/usr/bin:/bin',
        }
    }
    
    if ($extension_tag) {

        $ext_lock_path = "${phabdir}/extension_lock_${extension_tag}"

        git::install { 'phabricator/extensions':
            directory => "${phabdir}/extensions",
            git_tag   => $extension_tag,
            lock_file => $ext_lock_path,
            notify    => Exec[$ext_lock_path],
            before    => Git::Install['phabricator/phabricator'],
        }

        exec {$ext_lock_path:
            command => "touch ${ext_lock_path}",
            unless  => "test -z ${ext_lock_path} || test -e ${ext_lock_path}",
            path    => '/usr/bin:/bin',
        }

        phabricator::extension { $extensions:
            rootdir => $phabdir,
            require => Git::Install['phabricator/extensions'],
        }

    }

    #we ensure lock exists if string is not null
    exec {"ensure_lock_${lock_file}":
        command => "touch ${lock_file}",
        unless  => "test -z ${lock_file} || test -e ${lock_file}",
        path    => '/usr/bin:/bin',
    }

    # Create the database for Phabricator.
    $storage_bin = "${phabricator_path}/bin/storage"

    exec { 'install phabricator database':
        command => shellquote($storage_bin, 'upgrade', '-f'),
        unless => shellquote($storage_bin, 'status'),
        subscribe => Vcsrepo[$phabricator_path],
    }
}
