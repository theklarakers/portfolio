ifndef PROJECT_NAME
$(error Please define the project name (alphanumeric characters only) in a variable named PROJECT_NAME)
endif

__GITHUB_REPO_URL="https://$(shell git config --get remote.origin.url | sed -e 's/git@//g' -e 's/\.git//g' -e 's/:/\//g')"
__PROJECT_NAME_UPPERCASE="$(shell echo $(PROJECT_NAME) | tr [a-z] [A-Z])"

define __HELP_HEADER
	echo "   All rights reserved "
	echo "------------------------------------------"
	echo "  > $(__PROJECT_NAME_UPPERCASE)"
	echo "------------------------------------------"
endef

# Finds all targets defined in the included makefiles that are annotated
# with '## target: description' and lists them in alphabetical order
define __HELP_SCRIPT
	$(__HELP_HEADER)
	echo ''
	echo 'Usage: '
	echo '  make <target>'
	echo ''
	echo 'Targets:'
	grep -hE '^## [a-zA-Z_\/\.-]+: .+$$' $(MAKEFILE_LIST) \
		| sed 's/## //g' \
		| sort -V \
		| awk \
			-v maxlen=$$(grep -ohE '^## [a-zA-Z_\/\.-]+:' $(MAKEFILE_LIST) | awk '{ print length() | "sort -rn" }' | head -n 1) \
			'BEGIN {FS = ": "}; {printf "  \033[36m%-*s\033[0m %s\n", maxlen, $$1, $$2}'
endef

## help: Show available targets and their description
.PHONY: help
help:
	@$(__HELP_SCRIPT)