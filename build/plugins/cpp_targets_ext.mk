# header only dependency
define nativecpp_external_headers
  NATIVECPP_EXT_$(1)_INCDIR:=$(2)
endef

# header, libdir, and potentially library dependencies
define nativecpp_external_libraries
  $(eval $(call nativecpp_external_headers,$(1),$(2)))
  NATIVECPP_EXT_$(1)_LIBDIR:=$(3)
  NATIVECPP_EXT_$(1)_LIBS:=$(4)
endef

# a lazy man package layout, takes single additional argument
# and does the following: -Ix/include, -Lx/lib, -lx/lib/lib*.so
# called lousy because this approach to dependency definition
# may link lots of unused libraries into build artifacts
define lousy_nativecpp_external
  $(eval $(call nativecpp_external_headers,$(1),$(2)/include))
  NATIVECPP_EXT_$(1)_LIBDIR:=$(2)/lib
  NATIVECPP_EXT_$(1)_LIBS:=$$(patsubst lib%.so,%,$$(notdir $$(wildcard $$(NATIVECPP_EXT_$(1)_LIBDIR)/lib*.so)))
endef

# one of possible ways to implement native dependencies

$(eval $(call nativecpp_external_headers,boost.string,/usr/include))
$(eval $(call nativecpp_external_libraries,boost.date_time,/usr/include,/usr/lib/x86_64-linux-gnu,boost_date_time))
$(eval $(call lousy_nativecpp_external,boost.everything,/home/me/boost-1.55/include,/home/me/boost-1.55/lib))
