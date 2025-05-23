// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#include "js_export.h"

#include "core/framework/op_kernel.h"

const void* JsepOutput(void* context, int index, const void* data) {
  const uintptr_t* data_offset = reinterpret_cast<const uintptr_t*>(data);
  uintptr_t dim = *data_offset++;
  size_t dim_size = static_cast<size_t>(dim);
  std::vector<int64_t> dims(dim_size);
  for (size_t i = 0; i < dim_size; i++) {
    dims[i] = static_cast<int64_t>(*data_offset++);
  }

  LOGF_DEFAULT(VERBOSE, "JsepOutput(%d, %s)", index, onnxruntime::TensorShape(dims).ToString().c_str());

  auto output = reinterpret_cast<onnxruntime::OpKernelContext*>(context)->Output(index, onnxruntime::TensorShape(dims));
  auto r = output->DataRaw();

  LOGF_DEFAULT(VERBOSE, "JsepOutput -- data=%zu", (size_t)(r));
  return r;
}

const void* JsepGetNodeName(const void* kernel) {
  const auto& name = reinterpret_cast<const onnxruntime::OpKernel*>(kernel)->Node().Name();
  return name.c_str();
}
