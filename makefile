CMAKE       := cmake -GNinja ..
CMAKE_DBG   := $(CMAKE) -DCMAKE_BUILD_TYPE=Debug
NINJA       := ninja
MKDIR       := mkdir -p
MKDIR_BUILD := $(MKDIR) build && cd build

git:
	git add . && \
	git commit -m "$(shell hostname)" && \
	git push

.PHONY: test install

test: 
	$(MKDIR_BUILD) && $(CMAKE_DBG) && $(NINJA) && ctest -VV

debug: 
	$(MKDIR_BUILD) && $(CMAKE_DBG) && $(NINJA)

clean:
	rm -r build

install:
	cd build && $(NINJA) install

uninstall:
	cd build && xargs rm < install_manifest.txt
