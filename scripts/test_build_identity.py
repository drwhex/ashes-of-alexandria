"""Check that volatile build identity reaches only BuildInfo.cpp."""
from pathlib import Path
import os
import runpy
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
MODULE = runpy.run_path(str(ROOT / "scripts/git_branch.py"))

class Env(dict):
    def __init__(self, name, build_dir):
        super().__init__(PROJECT_DIR=str(ROOT), PIOENV=name, BUILD_DIR=build_dir)
        self.defines = []
        self.cpppath = []
    def Append(self, **kwargs):
        self.defines.extend(kwargs.get("CPPDEFINES", []))
        self.cpppath.extend(kwargs.get("CPPPATH", []))
    def subst(self, value): return value.replace("$BUILD_DIR", self["BUILD_DIR"])

class BuildIdentityTest(unittest.TestCase):
    def test_identity_only_changes_one_compile_environment(self):
        function = MODULE["inject_version"]
        globals_ = function.__globals__
        previous = globals_["get_git_short_sha"]
        self.addCleanup(globals_.__setitem__, "get_git_short_sha", previous)
        build_info = (ROOT / "src/util/BuildInfo.cpp").read_text(encoding="utf-8")
        self.assertIn("#include <CrossInkBuildIdentity.h>", build_info)
        for name in ("default", "sticky", "x4-pro", "x4-classic", "debug", "sticky-debug", "x4-pro-debug", "test", "gh_release_rc", "x4-pro-simulator"):
            captures = []
            for sha in ("abc1234", "def5678"):
                globals_["get_git_short_sha"] = lambda _: sha
                with tempfile.TemporaryDirectory() as build_dir:
                    env = Env(name, build_dir)
                    function(env)
                    include_dir = os.path.join(build_dir, "crossink_build_identity")
                    self.assertEqual(env.cpppath, [include_dir])
                    header = Path(include_dir, "CrossInkBuildIdentity.h").read_text(encoding="utf-8")
                names = [d[0] for d in env.defines if isinstance(d, tuple)]
                self.assertNotIn("CROSSINK_GIT_SHA", names)
                self.assertNotIn("CROSSINK_GIT_DIRTY", names)
                self.assertNotIn("CROSSINK_VERSION", names)
                self.assertIn(f'#define CROSSINK_GIT_SHA "{sha}"', header)
                if name != "x4-pro-simulator":
                    self.assertIn("#define CROSSINK_VERSION \"", header)
                self.assertNotIn("\\", header)
                captures.append((env.defines, env.cpppath[0].replace(build_dir, ""), header))
            self.assertEqual(captures[0][:2], captures[1][:2])
            self.assertNotEqual(captures[0][2], captures[1][2])

    def test_header_is_not_rewritten_when_unchanged(self):
        write = MODULE["write_build_identity_header"]
        scoped = [("CROSSINK_VERSION", '\\"0.0.2-x4-pro\\"')]
        with tempfile.TemporaryDirectory() as include_dir:
            path = write(include_dir, scoped)
            os.utime(path, (1, 1))
            write(include_dir, scoped)
            self.assertEqual(os.stat(path).st_mtime, 1)
            self.assertIn('#define CROSSINK_VERSION "0.0.2-x4-pro"', Path(path).read_text(encoding="utf-8"))

if __name__ == "__main__": unittest.main()
