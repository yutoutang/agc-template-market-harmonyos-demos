# the minimum version of CMake.
cmake_minimum_required(VERSION 3.4.1)
project(CameraSample)

set(NATIVERENDER_ROOT_PATH ${CMAKE_CURRENT_SOURCE_DIR})
add_definitions(-DOHOS_PLATFORM) #must add this

include_directories(${NATIVERENDER_ROOT_PATH}
                    ${NATIVERENDER_ROOT_PATH}/include
                    ${NATIVERENDER_ROOT_PATH}/capbilities/include
                    ${NATIVERENDER_ROOT_PATH}/common
                    ${NATIVERENDER_ROOT_PATH}/common/dfx/err
                    ${NATIVERENDER_ROOT_PATH}/common/dfx/log
                    ${NATIVERENDER_ROOT_PATH}/sample/recorder
                    ${NATIVERENDER_ROOT_PATH}/sample/player
)

add_library(nativerender SHARED
    main.cpp
    camera/ndk_camera.cpp
    render/egl_render_context.cpp
    render/render_thread.cpp
    render/plugin_render.cpp
    render/shader_program.cpp
    manager/plugin_manager.cpp
    sample/recorder/Recorder.cpp
    capbilities/muxer.cpp
    capbilities/video_encoder.cpp
    sample/player/Player.cpp
    capbilities/demuxer.cpp
    capbilities/video_decoder.cpp
    common/sample_callback.cpp
)

find_library(
    # Sets the name of the path variable.
    native-drawing-lib
    # Specifies the name of the NDK library that
    # you want CMake to locate.
    native_drawing
)

find_library(
    # Sets the name of the path variable.
    native-window-lib
    # Specifies the name of the NDK library that
    # you want CMake to locate.
    native_window
)

find_library(
    # Sets the name of the path variable.
    hilog-lib
    # Specifies the name of the NDK library that
    # you want CMake to locate.
    hilog_ndk.z
)

find_library(
    # Sets the name of the path variable.
    libace-lib
    # Specifies the name of the NDK library that
    # you want CMake to locate.
    ace_ndk.z
)

find_library(
    # Sets the name of the path variable.
    libnapi-lib
    # Specifies the name of the NDK library that
    # you want CMake to locate.
    ace_napi.z
)

target_link_libraries(nativerender PUBLIC
    libohcamera.so
    libace_napi.z.so libhilog_ndk.z.so libace_ndk.z.so
    libnative_media_codecbase.so libnative_media_core.so libnative_media_avsource.so
    libnative_media_venc.so libnative_media_vdec.so libnative_media_avmuxer.so libnative_media_avdemuxer.so
    libEGL.so libGLESv3.so libnative_image.so libnative_window.so libnative_buffer.so libnative_vsync.so
)
