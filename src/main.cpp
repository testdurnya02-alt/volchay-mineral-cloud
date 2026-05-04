#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>
#include <QFont>
#include <QFontDatabase>
#include <QIcon>

#include "ConverterController.h"
#include "Theme.h"

int main(int argc, char *argv[])
{
    QGuiApplication::setOrganizationName("Volchay");
    QGuiApplication::setApplicationName("Volchay-con-pro");
    QGuiApplication::setApplicationDisplayName("Volchay con Pro");
    QGuiApplication::setApplicationVersion("0.1.0");

    QGuiApplication app(argc, argv);

    QQuickStyle::setStyle("Basic");

    QFont base = app.font();
    base.setHintingPreference(QFont::PreferFullHinting);
    base.setStyleStrategy(QFont::PreferAntialias);
    app.setFont(base);

    ConverterController controller;
    Theme theme;

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("converter", &controller);
    engine.rootContext()->setContextProperty("theme", &theme);
    engine.load(QUrl(QStringLiteral("qrc:/qml/Main.qml")));

    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    return app.exec();
}
