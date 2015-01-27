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

# plugins directory (*.mk with arbitrary contents to be included in the build)
PLUGIN_DIR ?= $(ROOT_DIR)/plugins

$(info ROOT_DIR=$(ROOT_DIR))
$(info FILE_DIR=$(FILE_DIR))
$(info BASE_DIR=$(BASE_DIR))
$(info WORK_DIR=$(WORK_DIR))
$(info PLUGIN_DIR=$(PLUGIN_DIR))

# TODO: VL: checked inter-plugin dependencies, load plugins the same way the targets are loadeded
$(info loading plugins from $(ROOT_DIR)/plugins...)
-include $(PLUGIN_DIR)/*.mk

ifneq ($(ROOT_DIR),$(FILE_DIR)/build)
  $(info including project custom plugins from $(FILE_DIR)/build/plugins...)
  -include $(FILE_DIR)/build/plugins/*.mk
endif

REGISTERED_TARGETS :=

BUILDERS_PHONY_ARGS = MESSAGE
define BUILDERS_PHONY_CODE
.PHONY: $(1)
$(1):
	@echo "building $(1): $$(TARGETS_$(1)_MESSAGE)"
endef

define add_subtarget
  $(info compiling $(1)) # logged when doing $(call ...)
  $$(info processing $(1)) # logged when doing $(eval $(call ...))

  TARGET_TYPE := PHONY
  TARGET_BASE_DIR := $(abspath $(dir $(abspath $(1))))
  TARGET_REL_BASE_DIR := $$(TARGET_BASE_DIR:$(BASE_DIR)/%=%)
  TARGET_NAME := $$(subst /,_,$$(TARGET_REL_BASE_DIR))
  TARGET_MESSAGE := phony target $$(TARGET_NAME), nothing done
  TARGET_DEPENDS :=

  include $(abspath $(1))

  $$(if $$(strip $$(TARGET_NAME)),,$$(error empty target name: [$$(TARGET_NAME)]))

  $$(if $$(strip $$(filter $$(TARGET_NAME),$$(REGISTERED_TARGETS))),$$(error duplicate target name: [$$(TARGET_NAME)]))

  $$(if $$(strip $$(TARGET_TYPE)),,$$(error empty target type: [$$(TARGET_TYPE)]))

  $$(if $$(filter undefined,$$(origin BUILDERS_$$(TARGET_TYPE)_CODE)),$$(error unknown target type: [$$(TARGET_TYPE)]))

  BUILDER_CODE := $$(BUILDERS_$$(TARGET_TYPE)_CODE)

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

  endif
  
  # Do the same for the optional arguments
  # Write all required variables from TARGET_VARNAME to TARGETS_<TARGET_NAME>_VARNAME
  ifdef BUILDERS_$$(TARGET_TYPE)_OPTIONAL_ARGS
    BUILDER_ARGS := $$(BUILDERS_$$(TARGET_TYPE)_OPTIONAL_ARGS)

    # save target variables required by the requested builder in unique variables
    $$(foreach name,$$(BUILDER_ARGS),\
        $$(if $$(filter-out undefined,$$(origin TARGET_$$(name))),\
            $$(eval TARGETS_$$(TARGET_NAME)_$$(name) = $$(TARGET_$$(name)))\
        )\
    )

  endif

  TARGETS_$$(TARGET_NAME)_BASE_DIR:=$$(TARGET_BASE_DIR)
  TARGETS_$$(TARGET_NAME)_REL_BASE_DIR:=$$(TARGET_REL_BASE_DIR)
  TARGETS_$$(TARGET_NAME)_TYPE:=$$(TARGET_TYPE)
  $$(if $$(TARGET_DEPENDS),$$(eval TARGETS_$$(TARGET_NAME)_DEPENDS:=$$(TARGET_DEPENDS)))

  REGISTERED_TARGETS += $$(TARGET_NAME)

  $$(info processed $(1)) # logged when doing $(eval $(call ...))
  $(info compiled $(1)) # logged when doing $(call ...)
endef

# invocation of the above defined function on recursively found rules.mk files
$(foreach sub,$(shell find $(BASE_DIR) -mindepth 2 -type f -name rules.mk -print),\
    $(eval $(call add_subtarget,$(sub)))\
)

# validate no missing targets in dependencies (else topological sort loops forever)
# triggers an error when TARGET_DEPENDENDS in the rules.mk refers to a non-existing target
$(info checking for unresolved target dependencies...)
$(foreach tgt,$(REGISTERED_TARGETS),\
    $(if $(filter-out $(REGISTERED_TARGETS),$(TARGETS_$(tgt)_DEPENDS)),\
        $(error unknown targets [$(filter-out $(REGISTERED_TARGETS),$(TARGETS_$(tgt)_DEPENDS))] in dependency list of the target [$(tgt)])\
    )\
)

# sort targets topologically
$(info sorting targets topologically...)
REGISTERED_TARGETS_TOPOLOGICAL:=
REGISTERED_TARGETS_ALPHABETICAL:=$(sort $(REGISTERED_TARGETS))

define do_topological_sort
  REGISTERED_TARGETS_TOPOLOGICAL+=$$(foreach name,$$(REGISTERED_TARGETS_ALPHABETICAL),$$(if $$(filter-out $$(REGISTERED_TARGETS_TOPOLOGICAL),$$(TARGETS_$$(name)_DEPENDS)),,$$(name)))
  REGISTERED_TARGETS_ALPHABETICAL:=$$(filter-out $$(REGISTERED_TARGETS_TOPOLOGICAL),$$(REGISTERED_TARGETS_ALPHABETICAL))
  $$(if $(REGISTERED_TARGETS_ALPHABETICAL),$$(eval $$(call do_topological_sort)))
endef

$(eval $(call do_topological_sort))
REGISTERED_TARGETS_TOPOLOGICAL:=$(strip $(REGISTERED_TARGETS_TOPOLOGICAL))

$(info REGISTERED_TARGETS=$(REGISTERED_TARGETS))
$(info REGISTERED_TARGETS_TOPOLOGICAL=$(REGISTERED_TARGETS_TOPOLOGICAL))

$(info === BEGIN: dependencies graph (in the topological order) ===)
$(foreach name,$(REGISTERED_TARGETS_TOPOLOGICAL),\
  $(info $(name): $(TARGETS_$(name)_DEPENDS))\
)
$(info === END: dependencies graph (in the topological order) ===)

# run builder generation code in the topological order
$(foreach name,$(REGISTERED_TARGETS_TOPOLOGICAL),\
  $(info generating builder for [$(name)]...)\
  $(eval $(call BUILDERS_$(TARGETS_$(name)_TYPE)_CODE,$(name)))\
  $(eval all: | $(name))\
  $(info generated builder for [$(name)])\
)

$(info ### BUILD SYSTEM BOOTSTRAP LOG END ###)
$(info )
$(info ### BUILD LOG BEGIN ###)

.PHONY: all
all:
	@echo "making all targets..."

.PHONY: nothing
nothing:
	@echo "OK"

.PHONY: clean
clean:
	@echo "cleaning..."
