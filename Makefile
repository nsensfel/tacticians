################################################################################
## CONFIG ######################################################################
################################################################################
MODULES ?= css global login map-editor battle asset

SRC_DIR = ${CURDIR}/src
WWW_DIR = ${CURDIR}/www
DATA_DIR ?= /my/src/tacticians-data/

################################################################################
## MAKEFILE MAGIC ##############################################################
################################################################################
MODULES_SRC = $(addprefix $(SRC_DIR)/,$(MODULES))
MODULES_WWW = $(addprefix $(WWW_DIR)/,$(MODULES))

################################################################################
## SANITY CHECKS ###############################################################
################################################################################

################################################################################
## INCLUDES ####################################################################
################################################################################
main_target: all

include ${CURDIR}/mk/preprocessor.mk

################################################################################
## TARGET RULES ################################################################
################################################################################
all: $(PREPROCESSOR_RESULT) build $(WWW_DIR) $(MODULES_WWW)

upload_demo:
	scp -r $(WWW_DIR)/* dreamhost:~/tacticians.online/

build:
	for module in $(MODULES_SRC) ; do \
		$(MAKE) -C $$module build ; \
	done

clean:
	for module in $(MODULES_SRC) ; do \
		$(MAKE) -C $$module clean ; \
	done
	rm -f $(PREPROCESSED_FILES)

reset:
	$(MAKE) clean
	for module in $(MODULES_SRC) ; do \
		$(MAKE) -C $$module reset; \
	done

################################################################################
## INTERNAL RULES ##############################################################
################################################################################
$(MODULES_WWW): %:
	ln -s $(SRC_DIR)/$(patsubst $(WWW_DIR)/%,%,$@)/www/ $@

$(WWW_DIR):
	mkdir -p $@
