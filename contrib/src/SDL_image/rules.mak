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
	# 這裡先執行 configure，讓它生成基礎的 Makefile
	# configure 應該會使用 PKG_CONFIG_PATH 找到 sdl.pc，並設置一些默認的 CFLAGS
	cd $< && PKG_CONFIG_PATH=$(PREFIX)/lib/pkgconfig:$(PKG_CONFIG_PATH) \
		$(HOSTVARS) ./configure $(HOSTCONF) --enable-tif --disable-sdltest --disable-png

	# 然後，在實際的 make install 命令中，顯式地添加所需的 include 路徑
	# 這樣可以確保編譯器在 IMG.c 編譯時有正確的搜索路徑
	cd $< && $(MAKE) install CFLAGS="$(CFLAGS) -I$(PREFIX)/include -I$(PREFIX)/include/SDL"
	touch $@
