TEMPLATE = subdirs

SUBDIRS += \
    fluent_test_qt5 \
    src/FluentUI.pro \
    example
    example.depends = src/FluentUI.pro
