# MLX provider - Only supported on Apple Silicon (arm64)
if(NOT APPLE OR NOT CMAKE_SYSTEM_PROCESSOR STREQUAL "arm64")
  message(FATAL_ERROR "MLX is only supported on Apple Silicon (arm64)")
endif()

include(ExternalProject)

set(MLXC_VERSION "0.2.0")
set(MLXC_INSTALL_DIR ${CMAKE_CURRENT_BINARY_DIR}/mlxc_install)
set(MLXC_SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/mlxc_src)
set(MLXC_BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR}/mlxc_build)

ExternalProject_Add(
  mlxc_ext
  GIT_REPOSITORY https://github.com/ml-explore/mlx-c.git
  GIT_TAG v${MLXC_VERSION}
  SOURCE_DIR ${MLXC_SOURCE_DIR}
  BINARY_DIR ${MLXC_BINARY_DIR}
  CMAKE_ARGS
    -DCMAKE_INSTALL_PREFIX=${MLXC_INSTALL_DIR}
    -DBUILD_SHARED_LIBS=OFF
    -DMLX_C_BUILD_EXAMPLES=OFF
    -DMLX_C_USE_SYSTEM_MLX=OFF
  INSTALL_DIR ${MLXC_INSTALL_DIR}
  UPDATE_DISCONNECTED TRUE
)

# MLX provider source
set(MLX_ROOT ${PROJECT_SOURCE_DIR}/onnxruntime/core/providers/mlx)

file(GLOB_RECURSE onnxruntime_providers_mlx_src
  "${MLX_ROOT}/*.h"
  "${MLX_ROOT}/*.cc"
)

add_library(onnxruntime_providers_mlx ${onnxruntime_providers_mlx_src})
add_dependencies(onnxruntime_providers_mlx mlxc_ext)

# include paths
target_include_directories(onnxruntime_providers_mlx
  PRIVATE
    ${PROJECT_SOURCE_DIR}/include
    ${PROJECT_SOURCE_DIR}/onnxruntime
    ${PROJECT_SOURCE_DIR}/onnxruntime/core/providers/mlx
    ${CMAKE_CURRENT_BINARY_DIR}/onnx
    ${MLXC_INSTALL_DIR}/include
)

# link MLXC static lib manually
target_link_directories(onnxruntime_providers_mlx
  PRIVATE ${MLXC_INSTALL_DIR}/lib
)

target_link_libraries(onnxruntime_providers_mlx
  PRIVATE
    mlxc
    onnxruntime_common
    onnxruntime_framework
    onnxruntime_providers
    onnxruntime_util
    onnxruntime_graph
)

set_target_properties(onnxruntime_providers_mlx PROPERTIES FOLDER "ONNXRuntime")

install(TARGETS onnxruntime_providers_mlx
        ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
        LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})
