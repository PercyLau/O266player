# SDL_image

SDL_IMAGE_VERSION := 1.2.12
SDL_IMAGE_URL := http://www.libsdl.org/projects/SDL_image/release/SDL_image-$(SDL_IMAGE_VERSION).tar.gz

ifndef HAVE_DARWIN_OS
PKGS += SDL_image
endif
ifeq ($(call need_pkg,"SDL_image"),)
PKGS_FOUND += SDL_image
endif

$(TARBALLS)/SDL_image-$(SDL_IMAGE_VERSION).tar.gz:
	$(call download_pkg,$(SDL_IMAGE_URL),SDL_image)

.sum-SDL_image: SDL_image-$(SDL_IMAGE_VERSION).tar.gz

SDL_image: SDL_image-$(SDL_IMAGE_VERSION).tar.gz .sum-SDL_image
	$(UNPACK)
	$(APPLY) $(SRC)/SDL_image/SDL_image.patch
	$(APPLY) $(SRC)/SDL_image/pkg-config.patch
	$(UPDATE_AUTOCONFIG)
	$(MOVE)

DEPS_SDL_image = jpeg $(DEPS_jpeg) tiff $(DEPS_tiff) \
	sdl $(DEPS_sdl)

.SDL_image: SDL_image .sdl
	# 這裡添加或修改 CFLAGS 以包含 SDL 頭文件的具體路徑
	# 最可靠的方式是確保 configure 腳本接收到正確的 SDL_CFLAGS
	# 即使 configure 已經自動探測，也最好明確傳遞
	cd $< && PKG_CONFIG_PATH=$(PREFIX)/lib/pkgconfig:$(PKG_CONFIG_PATH) \
		$(HOSTVARS) ./configure $(HOSTCONF) --enable-tif --disable-sdltest --disable-png \
		# 添加這兩行，將 pkg-config 提供的正確路徑傳遞給 configure
		SDL_CFLAGS="$(shell $(PKG_CONFIG) --cflags sdl)" \
		SDL_LIBS="$(shell $(PKG_CONFIG) --libs sdl)"

	# 如果上面 configure 仍然有問題，可以嘗試在 make 命令中直接添加 CFLAGS
	# cd $< && $(HOSTVARS) CFLAGS="$(CFLAGS) $(shell $(PKG_CONFIG) --cflags sdl)" \
	# 	$(MAKE) install

	cd $< && $(MAKE) install
	touch $@
