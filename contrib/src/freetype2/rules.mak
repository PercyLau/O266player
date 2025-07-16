# freetype2

FREETYPE2_VERSION := 2.10.1
FREETYPE2_URL := $(SF)/freetype/freetype2/$(FREETYPE2_VERSION)/freetype-$(FREETYPE2_VERSION).tar.xz

PKGS += freetype2
ifeq ($(call need_pkg,"freetype2"),)
PKGS_FOUND += freetype2
endif

$(TARBALLS)/freetype-$(FREETYPE2_VERSION).tar.xz:
	$(call download_pkg,$(FREETYPE2_URL),freetype2)

.sum-freetype2: freetype-$(FREETYPE2_VERSION).tar.xz

freetype: freetype-$(FREETYPE2_VERSION).tar.xz .sum-freetype2
	$(UNPACK)
	$(call pkg_static, "builds/unix/freetype2.in")
	$(MOVE)

DEPS_freetype2 = zlib $(DEPS_zlib)

.freetype2: freetype
ifndef AD_CLAUSES
	$(REQUIRE_GPL)
endif
	cd $< && cp builds/unix/install-sh .
	sed -i.orig s/-ansi// $</builds/unix/configure
	
	# 運行 configure 命令，生成 Makefile
	cd $< && GNUMAKE=$(MAKE) $(HOSTVARS) \
		./configure --with-harfbuzz=no --with-zlib=yes --without-png --with-bzip2=no \
		$(HOSTCONF)
	
	# 關鍵修改：在 FreeType 的 Makefile 中插入 -mconsole 標誌
	# 注意這裡的 sed 替換可能需要根據實際生成的 Makefile 內容進行微調
	# 我們假設 FreeType 的 Makefile 中會定義 CFLAGS 和 LDFLAGS 變量，我們需要追加 -mconsole
	cd $< && sed -i 's/^\(BASE_CFLAGS = .*\)/\1 -mconsole/' Makefile
	cd $< && sed -i 's/^\(BASE_LDFLAGS = .*\)/\1 -mconsole/' Makefile
	# 如果是其他變量名，例如 CC_SHARED_FLAGS 或 LD_SHARED_FLAGS 等，則需要相應調整

	# 執行 make 和 make install
	cd $< && $(MAKE) && $(MAKE) install
	touch $@
