#!/usr/bin/env bash

.INCLUDE "${TEMPLATE_DIR}/_includes/_header.tpl"

# parse options
.INCLUDE "${TEMPLATE_DIR}/engine/installScript/optionsParse.sh"

# we need non root user to be sure that all variables will be correctly deduced
Assert::expectNonRootUser
