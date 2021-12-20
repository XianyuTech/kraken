/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_TEST_KRAKEN_TEST_ENV_H_
#define KRAKENBRIDGE_TEST_KRAKEN_TEST_ENV_H_

#include "bindings/qjs/bom/timer.h"
#include "bindings/qjs/dom/event_target.h"
#include "bindings/qjs/dom/frame_request_callback_collection.h"
#include "include/dart_methods.h"

using namespace kraken::binding::qjs;

void TEST_init(ExecutionContext* context);
int32_t TEST_setTimeout(DOMTimer* timer, int32_t contextId, AsyncCallback callback, int32_t timeout);
void TEST_clearTimeout(DOMTimer* timer);
uint32_t TEST_requestAnimationFrame(FrameCallback* frameCallback, AsyncRAFCallback handler);
void TEST_cancelAnimationFrame(JSContext* ctx, uint32_t callbackId);
void TEST_runLoop(ExecutionContext* context);
void TEST_dispatchEvent(EventTargetInstance* eventTarget, const std::string type);

#endif  // KRAKENBRIDGE_TEST_KRAKEN_TEST_ENV_H_
