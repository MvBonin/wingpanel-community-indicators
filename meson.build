# ----------------------------------------------------------------------------------------------------------------------
# Project: wingpanel-indicator-ayatana
#
# A Wingpanel indicator plug-in that adds ayatana indicator support.
# ----------------------------------------------------------------------------------------------------------------------
project('wingpanel-indicator-ayatana', 'vala', 'c')

sources = [
    'src/Indicator.vala',
    'src/MetaIndicator.vala',
    'src/NamarupaMetaIndicator.vala',
    'src/IndicatorButton.vala',
    'src/IndicatorFactory.vala',
    'src/IndicatorIface.vala',
    'src/IndicatorLoader.vala',
    'src/IndicatorObject.vala',
    'src/SubMenuButton.vala',
    'src/Settings.vala',
]
 wingpanel= dependency('wingpanel-2.0',required : false)
 if not wingpanel.found()
      wingpanel = dependency('wingpanel',required : true)
    endif
dependencies = {
    'json':     dependency('json-glib-1.0'),
    'granite':    dependency('granite'),
    'indicator3': dependency('indicator3-0.4'),
    'wingpanel': wingpanel
}

libdir = join_paths(get_option('prefix'), get_option('libdir'))

indicator_name = 'ayatana'
indicator_dir  = dependencies['wingpanel'].get_pkgconfig_variable('indicatorsdir', define_variable: ['libdir', libdir])

# ----------------------------------------------------------------------------------------------------------------------
# Bindings:

add_project_arguments(['--vapidir', join_paths(meson.current_source_dir(), 'vapi')],
                      language: 'vala')

# ----------------------------------------------------------------------------------------------------------------------
# Internationalization:

i18n = import('i18n')
gettext_name = indicator_name + '-indicator'

add_global_arguments('-DGETTEXT_PACKAGE="@0@"'.format(gettext_name),
                     language: 'c')

# ----------------------------------------------------------------------------------------------------------------------
# Generated constants:

constants = configuration_data()
constants.set_quoted('WINGPANEL_INDICATOR_DIR', join_paths(get_option('prefix'), indicator_dir))
constants.set_quoted('AYATANA_INDICATOR_DIR',   dependencies['indicator3'].get_pkgconfig_variable('indicatordir'))
constants.set_quoted('INDICATOR_NAME',          indicator_name)
constants.set_quoted('DATA_DIR',                join_paths(get_option('prefix'), get_option('datadir')))
constants.set_quoted('GETTEXT_PACKAGE',         gettext_name)

constants_file = configure_file(
    input: 'src/Constants.vala',
    output: 'Constants.vala',
    configuration: constants
)

# ----------------------------------------------------------------------------------------------------------------------
# Build:

deps = []
foreach _,v : dependencies
    deps += v
endforeach

shared_module(
    indicator_name,

    sources,
    constants_file,

    dependencies: deps,

    install:     true,
    install_dir: indicator_dir
)

