/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "kraken_bridge_export.h"
#include "dart_callbacks.h"
#include "bridge.h"
#include "polyfill.h"
#include <atomic>
#include <string>

kraken::DartFuncPointer funcPointer;
// this is not thread safe
std::atomic<bool> inited{false};
std::unique_ptr<kraken::JSBridge> bridge;
Screen screen;

void reloadJsContext() {
  inited = false;
  bridge = std::make_unique<kraken::JSBridge>();
  initKrakenPolyFill(bridge->getContext());
  inited = true;
}

void initJsEngine() {
  bridge = std::make_unique<kraken::JSBridge>();
  initKrakenPolyFill(bridge->getContext());
  inited = true;
}

void evaluateScripts(const char *code, const char *bundleFilename,
                      int startLine) {
  if (!inited) return;
  bridge->evaluateScript(std::string(code), std::string(bundleFilename),
                         startLine);
}

void invokeKrakenCallback(const char *data) {
  if (!inited) return;
  bridge->handleFlutterCallback(data);
}

void registerInvokeDartFromJS(InvokeDartFromJS callbacks) {
  kraken::registerInvokeDartFromJS(callbacks);
}

void registerReloadApp(ReloadApp reloadApp) {
  kraken::registerReloadApp(reloadApp);
}

void registerSetTimeout(SetTimeout setTimeout) {
  kraken::registerSetTimeout(setTimeout);
}

void registerSetInterval(SetInterval setInterval) {
  kraken::registerSetInterval(setInterval);
}

void registerClearTimeout(ClearTimeout clearTimeout) {
  kraken::registerClearTimeout(clearTimeout);
}

void registerRequestAnimationFrame(RequestAnimationFrame requestAnimationFrame) {
  kraken::registerRequestAnimationFrame(requestAnimationFrame);
}

void registerCancelAnimationFrame(CancelAnimationFrame cancelAnimationFrame) {
  kraken::registerCancelAnimationFrame(cancelAnimationFrame);
}

void registerGetScreen(GetScreen getScreen) {
  kraken::registerGetScreen(getScreen);
}

Screen *createScreen(double width, double height) {
  screen.width = width;
  screen.height = height;
  return &screen;
}
