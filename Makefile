INSTALL_PATH = /usr/local/bin/embed-alternate-icons

install:
	swift package clean
	swift package --enable-prefetching update
	swift build --enable-prefetching -c release -Xswiftc -static-stdlib
	cp -f .build/release/AlternateIcons $(INSTALL_PATH)

uninstall:
	rm -f $(INSTALL_PATH)
