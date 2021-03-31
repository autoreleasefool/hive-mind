# Remove cached repo and switch to local
rm -rf ./build && rm -rf Package.resolved
sed -i '' 's/git@github\.com:autoreleasefool\/hive-engine.git/..\/hive-engine/g' ./Package.swift
sed -i '' 's/\.\.\/hive-engine/git@github.com:autoreleasefool\/hive-engine.git/g' ./Package.swift

# Build and run performance tests
swift build
swift test --filter HiveMindCoreTests.CorePerformanceTests/testEvaluationPerformance

# # Reset Package.swift
rm -rf ./build && rm -rf Package.resolved
sed -i '' 's/\.\.\/hive-engine/git@github.com:autoreleasefool\/hive-engine.git/g' ./Package.swift
swift build
