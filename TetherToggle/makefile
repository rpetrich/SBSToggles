OBJECTS=Toggle
TARGET=Toggle.dylib
TOGGLE_NAME=TetherToggle

export NEXT_ROOT=/var/sdk

COMPILER=arm-apple-darwin9-gcc

LDFLAGS= \
		-dynamiclib \
		-Z \
		-F/var/sdk/System/Library/Frameworks \
		-F/var/sdk/System/Library/PrivateFrameworks \
		-L/var/sdk/lib \
		-L/var/sdk/usr/lib \
		-L/usr/lib \
		-Wall -Werror \
		-framework Foundation -framework CoreFoundation -framework Preferences -framework UIKit -framework CoreGraphics -lobjc \
		-multiply_defined suppress

CFLAGS= -I/var/root/Headers -I/var/sdk/include -I/var/include \
		-fno-common \
		-g0 -O2 \
		-std=c99

all:	$(TARGET)

clean:
		rm -f $(OBJECTS) $(TARGET) $(shell grep ^Package: control | cut -d ' ' -f 2)_*_iphoneos-arm.deb archive.tar.gz
		rm -rf package

archive: clean
		tar czf archive.tar.gz ./*

%:	%.m
		$(COMPILER) -c $(CFLAGS) $< -o $@

$(TARGET): $(OBJECTS)
		$(COMPILER) $(LDFLAGS) -o $@ $^
		ldid -S $@
		
package: $(TARGET) control
		rm -rf package
		mkdir -p package/DEBIAN
		cp -a control package/DEBIAN
		mkdir -p package/var/mobile/Library/SBSettings/Toggles/$(TOGGLE_NAME)/
		cp -a Toggle.dylib package/var/mobile/Library/SBSettings/Toggles/$(TOGGLE_NAME)/
		dpkg-deb -b package $(shell grep ^Package: control | cut -d ' ' -f 2)_$(shell grep ^Version: control | cut -d ' ' -f 2)_iphoneos-arm.deb
		
install: package
		dpkg -i $(shell grep ^Package: control | cut -d ' ' -f 2)_$(shell grep ^Version: control | cut -d ' ' -f 2)_iphoneos-arm.deb
		respring