TARGET := iphone:clang:7.0
ARCHS := armv7

include theos/makefiles/common.mk

LIBRARY_NAME = libVideoPlayer

libVideoPlayer_FILES = $(wildcard *.m *.cpp *.c)

libVideoPlayer_FRAMEWORKS = UIKit Foundation AudioToolbox QuartzCore OpenGLES

libVideoPlayer_OBJ_FILES = CHDataStructures.framework/Versions/A/CHDataStructures $(wildcard ffmpeg/lib/*.a)

libVideoPlayer_LDFLAGS = -lz -lbz2 -liconv

BUNDLE_NAME = VideoPlayer
VideoPlayer_INSTALL_PATH = /Library/PreferenceBundles

ADDITIONAL_CFLAGS = -Wno-unused-variable -Wno-unused-property-ivar -Iffmpeg/headers -ICHDataStructures.framework/Versions/A/Headers

include $(THEOS_MAKE_PATH)/library.mk
include $(THEOS_MAKE_PATH)/bundle.mk