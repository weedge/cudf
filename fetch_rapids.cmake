# =============================================================================
# Copyright (c) 2018-2023, NVIDIA CORPORATION.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except
# in compliance with the License. You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software distributed under the License
# is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express
# or implied. See the License for the specific language governing permissions and limitations under
# the License.
# =============================================================================
set(rapids-cmake-repo kkraus14/rapids-cmake)
set(rapids-cmake-branch spdlog_1.12_fmt_10)
if(NOT EXISTS ${CMAKE_CURRENT_BINARY_DIR}/CUDF_RAPIDS.cmake)
  file(DOWNLOAD https://raw.githubusercontent.com/rapidsai/rapids-cmake/branch-23.12/RAPIDS.cmake
       ${CMAKE_CURRENT_BINARY_DIR}/CUDF_RAPIDS.cmake
  )
endif()
include(${CMAKE_CURRENT_BINARY_DIR}/CUDF_RAPIDS.cmake)
