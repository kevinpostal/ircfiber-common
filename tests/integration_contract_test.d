/// Native, service-free compatibility contracts for site and engine consumers.
module integration_contract_test;

version (CommonIntegrationTest):
version (unittest) {} else static assert(false, "use --build=unittest for integration contracts");

import core.runtime : Runtime, UnitTestResult;
import std.stdio : writeln;
import ircfiber.async : safeFiberRun, watchedRunTask;
import ircfiber.errors;
import ircfiber.holder_client;
import ircfiber.irc.engine_janitor : EngineJanitor;
import ircfiber.logging : logException;
import ircfiber.db.upload_category : uploadCategory, uploadOriginalName;
import ircfiber.db.upload_library : uploadLibraryPage;
import vibe.core.task : Task;

// Compatibility is intentionally the strict, private reporting contract, not
// the old arbitrary-message/extra API. Migration belongs to process owners.
static assert(__traits(compiles,
    configureErrorReporting(false, "", "ircfiber-engine", "0.3.0", "test")));
static assert(!__traits(compiles,
    configureErrorReporting("http://key@localhost/1", "ircfiber-engine", "0.3.0")));
static assert(!__traits(compiles, setErrorReportingEnabled(true)));
static assert(__traits(compiles,
    captureException!("engine", "bootstrap")(new Exception("private"))));
static assert(!__traits(compiles,
    captureException("engine", new Exception("private"), "private context")));
static assert(is(typeof(safeFiberRun("event", "network", delegate void() {})) == Task));
static assert(is(typeof(watchedRunTask("label", "id", delegate void() {})) == Task));
static assert(is(typeof(EngineJanitor.init.runOnce()) == long));
static assert(__traits(compiles, logException("engine", new Exception("private"))));

private enum selected = [
    "ircfiber.errors",
    "ircfiber.holder_client",
    "ircfiber.db.history_suppression",
];

shared static this() {
    // Dependencies and other source modules may contain real-service tests.
    // Do not delegate to the default runner, even if a new module is added.
    Runtime.extendedModuleUnitTester = &runContracts;
}

private UnitTestResult runContracts() {
    UnitTestResult result;
    foreach (name; selected) {
        bool found;
        foreach (module_; ModuleInfo) {
            if (module_ is null || module_.name != name) continue;
            auto test = module_.unitTest;
            if (test is null) continue;
            found = true;
            ++result.executed;
            try {
                test();
                ++result.passed;
                writeln("PASS ", name);
            } catch (Throwable e) {
                writeln("FAIL ", name, ": ", e);
            }
        }
        if (!found) {
            ++result.executed;
            writeln("FAIL missing unittest module: ", name,
                " (use --build=unittest)");
        }
    }
    result.runMain = result.executed == result.passed;
    result.summarize = !result.runMain;
    return result;
}

void main() {
    enum stored = "0123456789abcdef0123456789abcdef.PY";
    assert(uploadCategory("", "image.SVG") == "image");
    assert(uploadCategory("application/pdf", "source.py") == "other");
    assert(uploadOriginalName("", "/uploads/" ~ stored, "renamed.pdf") == stored);
    bool ownerRejected;
    try uploadLibraryPage("");
    catch (Exception) ownerRejected = true;
    assert(ownerRejected, "ownerless upload library requests must fail before any database access");
    configureErrorReporting(false, "", "test", "1", "test");
    bool fiberRan, watchedRan;
    safeFiberRun("contract", "fixture", {
        fiberRan = true;
        throw new Exception("expected recoverable contract exception");
    }).join();
    watchedRunTask("contract", "fixture", {
        watchedRan = true;
        throw new Exception("expected recoverable contract exception");
    }).join();
    assert(fiberRan && watchedRan, "both async helpers retain recoverable Exception behavior");
    writeln("Common integration contracts: PASS (3 allowlisted modules, no external services)");
}
