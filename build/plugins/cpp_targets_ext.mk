define nativecpp_external_headers
  NATIVECPP_EXT_$(1)_INCDIR:=$(2)
endef

define nativecpp_external_libraries
  $(eval $(call nativecpp_external_headers,$(1),$(2)))
  NATIVECPP_EXT_$(1)_LIBDIR:=$(3)
  NATIVECPP_EXT_$(1)_LIBS:=$(4)
endef

# one of possible ways to implement native dependencies

$(eval $(call nativecpp_external_headers,boost.string,/usr/include))
$(eval $(call nativecpp_external_libraries,boost.date_time,/usr/include,/usr/lib/x86_64-linux-gnu,boost_date_time))
