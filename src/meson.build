lib_deps = [
    dependency('gio-2.0')
]

lib_sources = files(
	'corrupt-file.vala',
	'scanner.vala'
)

install_data(
    'deps.in',
    
    rename: lib_name + '.deps',
    install_dir: get_option('datadir') / 'vala' / 'vapi'
)

lib = library(
    lib_name,
    
    lib_sources,
    dependencies: lib_deps,
    vala_gir: gir_name + '.gir',
    vala_args: [ '--gresourcesdir=data/' ],
    install: true,
    install_dir: [true, true, true, true]
)

pkg.generate(
    name: meson.project_name(),
    description: 'Corrupt files finder library',
    
    libraries: lib,
    version: meson.project_version(),
    subdirs: lib_name,
    filebase: lib_name,
    requires: ['gtk4']
)

lib_dependency = declare_dependency(
    link_with: lib,
    include_directories: include_directories('.')
)
