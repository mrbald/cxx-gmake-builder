$(info ### BUILD SYSTEM BOOTSTRAP LOG BEGIN ###)

# absolute location of the makefile with symlinks dereferenced
# according to the plan it should point to the build system files
ROOT_DIR := $(abspath $(dir $(realpath $(lastword $(MAKEFILE_LIST)))))

# absolute location of the makefile with symlinks preserved
# according to the plan it should point to the top directory of the project
FILE_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

# project directory tree root
BASE_DIR ?= $(abspath $(FILE_DIR)/src)

# project build working area (obj, lib, bin, etc.)
WORK_DIR ?= $(PWD)

$(info ROOT_DIR=$(ROOT_DIR))
$(info FILE_DIR=$(FILE_DIR))
$(info BASE_DIR=$(BASE_DIR))
$(info WORK_DIR=$(WORK_DIR))

$(info loading plugins from $(ROOT_DIR)/plugins...)
-include $(ROOT_DIR)/plugins/*.mk

ifneq ($(ROOT_DIR),$(FILE_DIR)/build)
  $(info including project custom plugins from $(FILE_DIR)/build/plugins...)
  -include $(FILE_DIR)/build/plugins/*.mk
endif

KNOWN_TARGET_TYPES := PHONY
REGISTERED_TARGETS :=

BUILDERS_PHONY_ARGS = MESSAGE
define BUILDERS_PHONY_CODE
.PHONY: $(1)
$(1):
	@echo "building $(1): $$(TARGETS_$(1)_MESSAGE)"
endef

define add_subtarget
  $(info compiling $(1))
  $$(info processing $(1))

  TARGET_TYPE := PHONY
  TARGET_NAME := $(notdir $(abspath $(dir $(abspath $(1)))))
  TARGET_MESSAGE := phony target $$(TARGET_NAME), nothing done
  #TARGET_SOURCES := $$(abspath $$(wildcard $(dir $(abspath $(1)))/*.cc))
  TARGET_DEPENDS :=

  include $(abspath $(1))

  $$(if $$(strip $$(TARGET_NAME)),,$$(error empty target name: [$$(TARGET_NAME)]))

  $$(if $$(strip $$(filter $$(TARGET_NAME),$$(REGISTERED_TARGETS))),$$(error duplicate target name: [$$(TARGET_NAME)]))

  $$(if $$(strip $$(TARGET_TYPE)),,$$(error empty target type: [$$(TARGET_TYPE)]))

  $$(if $$(filter undefined,$$(origin BUILDERS_$$(TARGET_TYPE)_CODE)),$$(error unknown target type: [$$(TARGET_TYPE)]))
  #ifndef BUILDERS_$$(TARGET_TYPE)_CODE
  #  $$(error unknown target type: [$$(TARGET_TYPE)])
  #endif
  BUILDER_CODE := $$(BUILDERS_$$(TARGET_TYPE)_CODE)

  #$$(if $$(strip $$(filter $$(TARGET_TYPE),$$(KNOWN_TARGET_TYPES))),,$$(error unknown target type: [$$(TARGET_TYPE)]))

  $$(info registered: type:[$$(TARGET_TYPE)], name:[$$(TARGET_NAME)], depends on:[$$(TARGET_DEPENDS)])

  # Check that rules.mk have defined all files required for the target
  # Write all required variables from TARGET_VARNAME to TARGET_<TARGET_NAME>_VARNAME
  ifdef BUILDERS_$$(TARGET_TYPE)_ARGS
    BUILDER_ARGS := $$(BUILDERS_$$(TARGET_TYPE)_ARGS)

    $$(info validating builder arguments for $$(TARGET_NAME)/$$(TARGET_TYPE)...)

    $$(foreach name,$$(BUILDER_ARGS),\
        $$(if $$(filter undefined,$$(origin TARGET_$$(name))),\
            $$(error [$$(TARGET_NAME)] is missing mandatory argument [$$(name)] for the builder [$$(TARGET_TYPE)])\
        )\
    )

    # save target variables required by the requested builder in unique variables
    $$(foreach name,$$(BUILDER_ARGS),\
        $$(eval TARGETS_$$(TARGET_NAME)_$$(name) = $$(TARGET_$$(name)))\
    )

    # deferred assignment '=' below is on purpose
    #TARGETS_$$(TARGET_NAME)_ARGS := $$(BUILDERS_$$(TARGET_TYPE)_ARGS)
  endif
  # deferred assignment '=' below is on purpose
  #TARGETS_$$(TARGET_NAME)_CODE := $$(call $$(BUILDERS_$$(TARGET_TYPE)_CODE),$$(TARGET_NAME))

  #$$(info $$(call BUILDERS_$$(TARGET_TYPE)_CODE,$$(TARGET_NAME)))
  $$(eval $$(call BUILDERS_$$(TARGET_TYPE)_CODE,$$(TARGET_NAME)))

  #$$(info TARGET_DEPENDS:$$(TARGET_DEPENDS))
  $$(if $$(TARGET_DEPENDS),$$(eval $$(TARGET_NAME): $$(TARGET_DEPENDS:,= )))
  $$(if $$(TARGET_DEPENDS),$$(info $$(TARGET_NAME): $$(TARGET_DEPENDS:,= )))

  REGISTERED_TARGETS += $$(TARGET_NAME)

  $$(info processed $(1))
  $(info compiled $(1))
endef

# invocation of the above defined function on recursively found rules.mk files
$(foreach sub,$(shell find $(BASE_DIR) -mindepth 2 -type f -name rules.mk -print),\
    $(eval $(call add_subtarget,$(sub)))\
)

#$(eval $(call subtarged,config/rules.mk))
$(info REGISTERED_TARGETS=$(REGISTERED_TARGETS))

$(info ### BUILD SYSTEM BOOTSTRAP LOG END ###)
$(info )
$(info ### BUILD LOG BEGIN ###)

## instantiate rules
#$(foreach name,$(REGISTERED_TARGETS),\
#    $(info $(name) -- $(TARGETS_$(name)_CODE))\
#    $(eval $(TARGETS_$(name)_CODE))\
#)

.PHONY: all
all:
	@echo "making all targets..."

.PHONY: clean
clean:
	@echo "cleaning..."
