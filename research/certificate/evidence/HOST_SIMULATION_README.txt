These optional developer review scripts simulate Windows host APIs, WMI,
filesystem behavior and compiler responses entirely in memory. They are NOT
called by run.cmd and do not establish native execution or Lean certification.
The native Windows runner has no Node dependency.

Pass tools/native_runner.js as the first argument to each of cache_mock_tests.js,
helper_cache_mock_tests.js and lock_mock_tests.js in a Node environment to
reproduce the simulations. Keep these three test scripts side by side.
The reports record the exact tested runner hash. The sole Windows entry is
run.cmd; no Lean/C#/Windows compiler was run during package preparation.
