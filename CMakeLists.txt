cmake_minimum_required(VERSION 3.21)
project(VolchayConPro VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release)
endif()

find_package(Qt6 6.2 REQUIRED COMPONENTS
    Core
    Gui
    Qml
    Quick
    QuickControls2
    Svg
    Core5Compat
)

set(CXX_SOURCES
    src/main.cpp
    src/ConverterController.cpp
    src/Theme.cpp
    src/converters/EncodingConverter.cpp
    src/converters/ImageConverter.cpp
    src/converters/DataConverter.cpp
    src/converters/EncodeConverter.cpp
    src/converters/VideoConverter.cpp
)

set(CXX_HEADERS
    src/ConverterController.h
    src/converters/EncodingConverter.h
    src/converters/ImageConverter.h
    src/converters/DataConverter.h
    src/converters/EncodeConverter.h
    src/converters/VideoConverter.h
)

qt_add_executable(VolchayConPro WIN32 MACOSX_BUNDLE
    ${CXX_SOURCES}
    ${CXX_HEADERS}
    resources/qml.qrc
)

target_include_directories(VolchayConPro PRIVATE src)

target_link_libraries(VolchayConPro PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
    Qt6::QuickControls2
    Qt6::Svg
    Qt6::Core5Compat
)

set_target_properties(VolchayConPro PROPERTIES
    OUTPUT_NAME "Volchay-con-pro"
)

if(WIN32)
    set_target_properties(VolchayConPro PROPERTIES
        WIN32_EXECUTABLE ON
    )
endif()

install(TARGETS VolchayConPro
    BUNDLE  DESTINATION .
    RUNTIME DESTINATION bin
)
