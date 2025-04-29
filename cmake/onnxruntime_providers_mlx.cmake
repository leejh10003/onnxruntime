# MLX provider - Only supported on Apple Silicon (arm64)
if(NOT APPLE OR NOT CMAKE_SYSTEM_PROCESSOR STREQUAL "arm64")
  message(FATAL_ERROR "MLX is only supported on Apple Silicon (arm64)")
endif()

# MLX-C dependency
include(FetchContent)

set(MLXC_VERSION "0.2.0" CACHE STRING "MLX-C version")

# Build MLX-C from source
FetchContent_Declare(
  mlxc
  GIT_REPOSITORY https://github.com/ml-explore/mlx-c.git
  GIT_TAG v${MLXC_VERSION}
)

FetchContent_MakeAvailable(mlxc)
set(BUILD_SHARED_LIBS OFF CACHE BOOL "Build shared libraries" FORCE)
set(MLX_BUILD_TESTS OFF CACHE BOOL "Build tests" FORCE)
# Set binary dir explicitly in case FetchContent_Populate hasn't created it yet
if(NOT DEFINED mlxc_BINARY_DIR)
  set(mlxc_BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR}/_deps/mlxc-build)
endif()
#add_subdirectory(${mlxc_SOURCE_DIR} ${mlxc_BINARY_DIR} EXCLUDE_FROM_ALL)

# Set MLX provider path
set(MLX_ROOT ${PROJECT_SOURCE_DIR}/onnxruntime/core/providers/mlx)

file(GLOB_RECURSE onnxruntime_providers_mlx_src
  "${MLX_ROOT}/*.h"
  "${MLX_ROOT}/*.cc"
)

source_group(TREE ${MLX_ROOT} FILES ${onnxruntime_providers_mlx_src})

add_library(onnxruntime_providers_mlx ${onnxruntime_providers_mlx_src})
add_dependencies(onnxruntime_providers_mlx ${onnxruntime_EXTERNAL_DEPENDENCIES})

target_include_directories(onnxruntime_providers_mlx
  PRIVATE
    ${PROJECT_SOURCE_DIR}/include
    ${PROJECT_SOURCE_DIR}/onnxruntime
    ${PROJECT_SOURCE_DIR}/onnxruntime/core/providers/mlx
    ${CMAKE_CURRENT_BINARY_DIR}/onnx
    ${mlxc_SOURCE_DIR}/include
)

target_link_libraries(onnxruntime_providers_mlx PRIVATE mlxc)
target_link_libraries(onnxruntime_providers_mlx
  PRIVATE
    onnxruntime_common
    onnxruntime_framework
    onnxruntime_providers
    onnxruntime_util
    onnxruntime_graph
)

set_target_properties(onnxruntime_providers_mlx PROPERTIES FOLDER "ONNXRuntime")
install(TARGETS onnxruntime_providers_mlx
        ARCHIVE  DESTINATION ${CMAKE_INSTALL_LIBDIR}
        LIBRARY  DESTINATION ${CMAKE_INSTALL_LIBDIR}
        RUNTIME  DESTINATION ${CMAKE_INSTALL_BINDIR})
