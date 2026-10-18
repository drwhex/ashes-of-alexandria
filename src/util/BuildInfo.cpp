#include <AppVersion.h>

// Only this translation unit receives the changing version and Git defines,
// generated into the build directory by scripts/git_branch.py.
#if __has_include(<CrossInkBuildIdentity.h>)
#include <CrossInkBuildIdentity.h>
#endif

#ifndef CROSSINK_VERSION
#define CROSSINK_VERSION "dev"
#endif

#ifndef CROSSINK_GIT_SHA
#define CROSSINK_GIT_SHA "unknown"
#endif

#ifndef CROSSINK_GIT_DIRTY
#define CROSSINK_GIT_DIRTY "unknown"
#endif

namespace AppVersion {
const char* version() { return CROSSINK_VERSION; }
const char* versionLabel() { return "Ashes of Alexandria " CROSSINK_VERSION; }
const char* userAgent() { return "CrossInk-ESP32-" CROSSINK_VERSION; }
const char* gitSha() { return CROSSINK_GIT_SHA; }
const char* gitDirtyFlag() { return CROSSINK_GIT_DIRTY; }
}  // namespace AppVersion
