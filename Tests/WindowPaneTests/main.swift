import Foundation

let runner = TestRunner()

LayoutEngineTests.runAll(runner)
WindowCommandCodableTests.runAll(runner)
URLParsingTests.runAll(runner)
FuzzyMatchTests.runAll(runner)

print()
print(runner.summary)
exit(runner.exitCode)
