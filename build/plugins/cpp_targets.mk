$(info loading c++ targets...)

BUILDERS_CPPLIB_ARGS := SOURCES
define BUILDERS_CPPLIB_CODE
.PHONY: $(1)
$(1): lib$(1).so
lib$(1).so:
	@echo "building lib$(1).so"
endef

$(info loaded c++ targets...)
