$(info loading c++ targets...)

CC=cc
CXX=c++

# default compiler flags
DOLLAR:=$$
CPPFLAGS:=-MMD -I$(BASE_DIR)
CXXFLAGS:=-std=c++0x -m64 -fPIC -Wall -Wextra
LDFLAGS:=-m64 -fPIC -Wl,-zdefs -Wl,-znow -Wl,--enable-new-dtags -Wl,-rpath,$$$$(value DOLLAR)ORIGIN:$$$$(value DOLLAR)ORIGIN/../lib

BUILDERS_NATIVECPP_ARGS := ARTIFACT_TYPE REL_BASE_DIR
BUILDERS_NATIVECPP_OPTIONAL_ARGS := SOURCES INTERFACE_HEADERS EXTERNAL_DEPENDENCIES
# TODO: VL: support INTERFACE_HEADERS (should be installed to $(WORK_DIR)/include/...

define BUILDERS_NATIVECPP_CODE
$(info compiling [NATIVECPP] plugin code...)
$$(info processing [NATIVECPP] code for target [$(1)]...)

.PHONY: $(1)
.PHONY: clean-$(1)
.PHONY: build-$(1)

# attach to the "make all"
$(1): build-$(1)
clean: clean-$(1)

# auto-assign sources if none specified to $(wildcard *.cpp)
$$(if $$(filter undefined,$$(origin TARGETS_$(1)_SOURCES)),\
  $$(eval TARGETS_$(1)_SOURCES := $$(wildcard $(TARGETS_$(1)_BASE_DIR)/*.cpp))\
)

$$(eval TARGETS_$(1)_CPPFLAGS:=$(CPPFLAGS))
$$(eval TARGETS_$(1)_CXXFLAGS:=$(CXXFLAGS))
$$(eval TARGETS_$(1)_LDFLAGS:=$(LDFLAGS))

# update build flags with those required by third party dependencies
# TODO: VL: filter out duplicate incdirs and libdirs
$$(foreach name,$$(TARGETS_$(1)_EXTERNAL_DEPENDENCIES),\
    $$(if $$(filter-out undefined,$$(origin NATIVECPP_EXT_$$(name)_INCDIR)),\
        $$(eval TARGETS_$(1)_CPPFLAGS+=-I$$(NATIVECPP_EXT_$$(name)_INCDIR))\
    )\
    $$(if $$(filter-out undefined,$$(origin NATIVECPP_EXT_$$(name)_LIBDIR)),\
        $$(eval TARGETS_$(1)_LDFLAGS+=-L$$(NATIVECPP_EXT_$$(name)_LIBDIR) -Wl,-rpath,$$(NATIVECPP_EXT_$$(name)_LIBDIR))\
    )\
    $$(if $$(filter-out undefined,$$(origin NATIVECPP_EXT_$$(name)_LIBS)),\
        $$(foreach libname,$$(NATIVECPP_EXT_$$(name)_LIBS),\
            $$(eval TARGETS_$(1)_LDFLAGS+=-l$$(libname))\
        )\
    )\
)

# update build flags with those required by in-project dependencies
# TODO: VL: filter out duplicate incdirs and libdirs
$$(foreach name,$$(TARGETS_$(1)_DEPENDS),\
    $$(if $$(filter NATIVECPP,$$(TARGETS_$$(name)_TYPE)),\
        $$(if $$(filter SHARED_LIBRARY,$$(TARGETS_$$(name)_ARTIFACT_TYPE)),\
            $$(eval TARGETS_$(1)_LDFLAGS+=-L$(WORK_DIR)/lib -l$$(name))\
            $$(eval TARGETS_$(1)_CPPFLAGS+=$$(TARGETS_$$(name)_CPPFLAGS))\
        )\
    )\
)

$$(eval TARGETS_$(1)_OBJS := $$(TARGETS_$(1)_SOURCES:%.cpp=%.o))
$$(eval TARGETS_$(1)_OBJS := $$(TARGETS_$(1)_OBJS:$(BASE_DIR)/%=$(WORK_DIR)/obj/%))

$$(info TARGETS_$(1)_SOURCES = $$(TARGETS_$(1)_SOURCES))
#$$(info TARGETS_$(1)_CPPFLAGS = $$(TARGETS_$(1)_CPPFLAGS))
#$$(info TARGETS_$(1)_CXXFLAGS = $$(TARGETS_$(1)_CXXFLAGS))
#$$(info TARGETS_$(1)_LDFLAGS = $$(TARGETS_$(1)_LDFLAGS))
$$(info TARGETS_$(1)_OBJS=$$(TARGETS_$(1)_OBJS))
$$(info TARGETS_$(1)_DEPENDS=$$(TARGETS_$(1)_DEPENDS))

# make sure dependencies are built first, but in the order-only ("|" below) mode
$$(TARGETS_$(1)_OBJS): | $$(TARGETS_$(1)_DEPENDS)

ifeq ($(TARGETS_$(1)_ARTIFACT_TYPE),SHARED_LIBRARY)

build-$(1): $(WORK_DIR)/lib/lib$(1).so

clean-$(1):
	@/bin/rm -f $(WORK_DIR)/lib/lib$(1).so
	@/bin/rm -rf $(WORK_DIR)/obj/$(TARGETS_$(1)_REL_BASE_DIR)

$(WORK_DIR)/lib/lib$(1).so: $$(TARGETS_$(1)_OBJS)
	@echo "linking shared library $$@"
	@/bin/mkdir -p "$(WORK_DIR)/lib"
	$(CXX) -shared -Wl,-soname,$$@ -o $$@ $$(TARGETS_$(1)_OBJS) $$(TARGETS_$(1)_LDFLAGS)

else ifeq ($(TARGETS_$(1)_ARTIFACT_TYPE),EXECUTABLE)

build-$(1): $(WORK_DIR)/bin/$(1)

clean-$(1):
	@/bin/rm -f $(WORK_DIR)/bin/$(1)
	@/bin/rm -rf $(WORK_DIR)/obj/$(TARGETS_$(1)_REL_BASE_DIR)

$(WORK_DIR)/bin/$(1): $$(TARGETS_$(1)_OBJS)
	@echo "linking binary $(1)"
	@/bin/mkdir -p "$(WORK_DIR)/bin"
	$(CXX) -o $$@ $$(TARGETS_$(1)_OBJS) $$(TARGETS_$(1)_LDFLAGS)
else

$$(error unsupported target artifact type: [$(TARGETS_$(1)_ARTIFACT_TYPE)])

endif

$(WORK_DIR)/obj/$(TARGETS_$(1)_REL_BASE_DIR)/%.o: $(BASE_DIR)/$(TARGETS_$(1)_REL_BASE_DIR)/%.cpp
	@echo "compiling $$@ from $$<"
	@/bin/mkdir -p "$(WORK_DIR)/obj/$(TARGETS_$(1)_REL_BASE_DIR)"
	$(CXX) -c -o $$@ $$(TARGETS_$(1)_CPPFLAGS) $$(TARGETS_$(1)_CXXFLAGS) $$<

-include $$(TARGETS_$(1)_OBJS:%.o=%.d)

$$(info processed [NATIVECPP] code for target [$(1)])
$(info compiled [NATIVECPP] plugin code)
endef

$(info loaded c++ targets)
