define phabricator::libext ($phabdir, $libext_tag, $libname, $libext_lock_path) {
      git::install { "phabricator/extensions/${libname}" :
            directory => "${phabdir}/libext/${libname}",
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
