$(info loading c++ targets...)

CC=cc
CXX=c++
CPPFLAGS:=-MMD -I$(BASE_DIR)
CXXFLAGS:=-std=c++0x -m64 -fPIC -Wall -Wextra
LDFLAGS:=-m64 -fPIC -Wl,-zdefs -Wl,-znow

BUILDERS_NATIVECPP_ARGS := SOURCES ARTIFACT_TYPE REL_BASE_DIR
define BUILDERS_NATIVECPP_CODE
$(info compiling [NATIVECPP] code for target [$(1)]...)
$$(info processing [NATIVECPP]code for target [$(1)]...)

# attach to the "make all"
all: build-$(1)
clean: clean-$(1)

.PHONY: clean-$(1)
.PHONY: build-$(1)

TARGETS_$(1)_OBJS := $(TARGETS_$(1)_SOURCES:%.cpp=%.o)
TARGETS_$(1)_OBJS := $$(TARGETS_$(1)_OBJS:$(BASE_DIR)/%=$(WORK_DIR)/obj/%)
$$(info TARGETS_$(1)_OBJS=$$(TARGETS_$(1)_OBJS))

ifeq ($(TARGETS_$(1)_ARTIFACT_TYPE),SOLIB)

build-$(1): $(WORK_DIR)/lib/lib$(1).so

clean-$(1):
	@/bin/rm -f $(WORK_DIR)/lib/lib$(1).so
	@/bin/rm -rf $(WORK_DIR)/obj/$(TARGETS_$(1)_REL_BASE_DIR)

$(WORK_DIR)/lib/lib$(1).so: $$(TARGETS_$(1)_OBJS)
	@echo "linking shared library lib$(1).so"
	@/bin/mkdir -p "$(WORK_DIR)/lib"
	$(CXX) -shared -Wl,-soname,$$@.1 -o $$@ $$^ $(LDFLAGS)

else

build-$(1): $(WORK_DIR)/bin/$(1)

clean-$(1):
	@/bin/rm -f $(WORK_DIR)/bin/$(1)
	@/bin/rm -rf $(WORK_DIR)/obj/$(TARGETS_$(1)_REL_BASE_DIR)

$(WORK_DIR)/lib/$(1): $$(TARGETS_$(1)_OBJS)
	@echo "linking binary $(1)"
	@/bin/mkdir -p "$(WORK_DIR)/bin"
	$(CXX) -o $$@ $$^ $(LDFLAGS)

endif

$(WORK_DIR)/obj/$(TARGETS_$(1)_REL_BASE_DIR)/%.o: $(BASE_DIR)/$(TARGETS_$(1)_REL_BASE_DIR)/%.cpp
	@echo "compiling $$@ from $$^"
	@/bin/mkdir -p "$(WORK_DIR)/obj/$(TARGETS_$(1)_REL_BASE_DIR)"
	$(CXX) -c -o $$@ $(CPPFLAGS) $(CXXFLAGS) $$^

-include $$(TARGETS_$(1)_OBJS:%.o=%.d)

$$(info processing [NATIVECPP] code for target [$(1)]...)
$(info compiled [NATIVECPP] code for target [$(1)]...)
endef

$(info loaded c++ targets...)
