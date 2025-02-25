#!/bin/bash

# Copyright 2020 The OpenEBS Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -o errexit
set -o nounset
set -o pipefail

echo "# This manifest is autogenerated via 'make manifests' command." > deploy/cstor-operator.yaml
echo "# Do the modification to the yamls in deploy/yamls/  directory" >> deploy/cstor-operator.yaml
echo "# and then run 'make manifests' command" >> deploy/cstor-operator.yaml
echo "#" >> deploy/cstor-operator.yaml
echo "# NDM Operator YAML will be downladed from github.com/openebs/node-disk-manager repo" >> deploy/cstor-operator.yaml
echo "" >> deploy/cstor-operator.yaml

# Add namespace & required rbac for creation of cStor-operator yaml
cat deploy/yamls/rbac.yaml >> deploy/cstor-operator.yaml

# Add cStor related CRDs to the Operator yaml
cat deploy/crds/all_cstor_crds.yaml >> deploy/cstor-operator.yaml

## Fetch NDM Operator from https://github.com/openebs/node-disk-manager
wget https://raw.githubusercontent.com/openebs/node-disk-manager/HEAD/deploy/ndm-operator.yaml -O deploy/yamls/ndm-operator.yaml

## Update the SPARSE_FILE_COUNT env value in ndm-operator.yaml
##
## !b negates the previous address and breaks out of any processing, end the sed commands,
## n prints the current line and reads the next line into pattern space,
## c changes the current line to the string following command
sed -i '/SPARSE_FILE_COUNT/!b;n;c\          value: "1"' deploy/yamls/ndm-operator.yaml

## Add the ndm-operator yaml to manifest
cat deploy/yamls/ndm-operator.yaml >> deploy/cstor-operator.yaml

# Add the cStor-csi resources to the Operator yaml
cat deploy/yamls/csi-operator.yaml >> deploy/cstor-operator.yaml

# Add the cstor-operator resources to the Operator yaml
cat deploy/yamls/cspc-operator.yaml >> deploy/cstor-operator.yaml

echo "Successfully generated cstor-operator.yaml"
