# ═══════════════════════════════════════════════════════════════════════
# DEERFLOW ALGORITHMS — Agent Decision Engine v1.0
# ═══════════════════════════════════════════════════════════════════════
# This file defines the core algorithms that govern agent behavior.
# These are deterministic decision trees that agents MUST follow.
# ═══════════════════════════════════════════════════════════════════════

## ALGORITHM 1: TASK CLASSIFICATION ENGINE

```
INPUT: User task description
OUTPUT: Task type + Required skills + Risk level

FUNCTION classify_task(task):
  features = extract_features(task)

  IF features.has_keywords(["document", "report", "pdf", "docx", "xlsx", "ppt"]):
    RETURN { type: "DOCUMENT", skills: ["docx/pdf/xlsx"], risk: "LOW" }

  IF features.has_keywords(["chart", "diagram", "visualization", "mermaid"]):
    RETURN { type: "VISUALIZATION", skills: ["charts"], risk: "LOW" }

  IF features.has_keywords(["webpage", "web app", "dashboard", "interactive"]):
    IF features.has_keywords(["real-time", "websocket", "collaborative"]):
      RETURN { type: "WEB_APP_COMPLEX", skills: ["fullstack"], risk: "HIGH" }
    RETURN { type: "WEB_APP", skills: ["fullstack"], risk: "MEDIUM" }

  IF features.has_keywords(["analyze", "process", "transform", "clean"]):
    RETURN { type: "DATA_PROCESSING", skills: ["python"], risk: "LOW" }

  IF features.has_keywords(["fix", "bug", "error", "debug"]):
    RETURN { type: "BUG_FIX", skills: ["code-review", "testing"], risk: "MEDIUM" }

  IF features.has_keywords(["refactor", "optimize", "improve"]):
    RETURN { type: "REFACTORING", skills: ["code-review", "architecture"], risk: "HIGH" }

  IF features.has_keywords(["test", "spec", "coverage"]):
    RETURN { type: "TESTING", skills: ["testing"], risk: "LOW" }

  RETURN { type: "UNKNOWN", skills: ["deep-search"], risk: "MEDIUM" }
```

## ALGORITHM 2: IMPLEMENTATION STRATEGY SELECTOR

```
INPUT: Task type + Requirements
OUTPUT: Implementation strategy

FUNCTION select_strategy(task, requirements):
  candidates = generate_strategies(requirements)

  FOR each strategy IN candidates:
    score = 0
    score += CORRECTNESS_WEIGHT * evaluate_correctness(strategy)
    score += MAINTAINABILITY_WEIGHT * evaluate_maintainability(strategy)
    score += PERFORMANCE_WEIGHT * evaluate_performance(strategy)
    score += SIMPLICITY_WEIGHT * evaluate_simplicity(strategy)
    score += SCALABILITY_WEIGHT * evaluate_scalability(strategy)
    strategy.score = score

  // Sort by score descending
  candidates.sort((a, b) => b.score - a.score)

  // Validate top choice
  best = candidates[0]
  validation = validate_strategy(best)

  IF validation.passes:
    RETURN best
  ELSE:
    // Try next best
    FOR candidate IN candidates[1:]:
      IF validate_strategy(candidate).passes:
        RETURN candidate

  RETURN FALLBACK_STRATEGY  // Simplest that works
```

## ALGORITHM 3: DEPENDENCY CONFLICT RESOLVER

```
INPUT: Package to install + Current dependency tree
OUTPUT: Installation plan or CONFLICT_ERROR

FUNCTION resolve_dependency(package_name, version, dep_tree):
  package_info = fetch_package_info(package_name)

  // Check peer dependencies
  FOR each peer_dep IN package_info.peerDependencies:
    IF peer_dep NOT in dep_tree:
      WARNING(f"Missing peer dependency: {peer_dep}")
      dep_tree.add(peer_dep)

    ELSE IF dep_tree[peer_dep].version NOT compatible with peer_dep.range:
      RETURN CONFLICT_ERROR({
        package: package_name,
        conflicts_with: peer_dep,
        current_version: dep_tree[peer_dep].version,
        required_range: peer_dep.range
      })

  // Check for known conflicts
  known_conflicts = check_conflict_database(package_name, dep_tree)
  IF known_conflicts.length > 0:
    RETURN CONFLICT_ERROR({
      package: package_name,
      known_conflicts: known_conflicts
    })

  // Check for duplicate functionality
  duplicates = find_functional_duplicates(package_name, dep_tree)
  IF duplicates.length > 0:
    WARNING(f"Potential duplicate: {package_name} provides similar
             functionality to {duplicates}")

  RETURN SUCCESS({
    install: package_name + "@" + version,
    additional: peer_deps_to_install,
    warnings: duplicates
  })
```

## ALGORITHM 4: CONTEXT DECAY PREVENTION

```
INPUT: Current session state + Token limit
OUTPUT: Context management action

FUNCTION manage_context(session, token_limit):
  usage_percent = session.tokens_used / token_limit * 100

  IF usage_percent > 80:
    // CRITICAL: Must compress immediately
    summary = generate_session_summary(session)
    session.history = [summary]
    session.compressed = true
    LOG("Context compressed at ${usage_percent}% usage")
    RETURN { action: "COMPRESS", summary: summary }

  IF usage_percent > 60:
    // WARNING: Prepare for compression
    session.summary_checkpoint = generate_partial_summary(session)
    LOG("Summary checkpoint created at ${usage_percent}% usage")
    RETURN { action: "PREPARE_COMPRESS" }

  // Normal operation — but track changes
  IF session.actions_since_last_summary > 10:
    session.partial_summary = update_partial_summary(session)
    RETURN { action: "UPDATE_SUMMARY" }

  RETURN { action: "NONE" }
```

## ALGORITHM 5: QUALITY GATE EVALUATOR

```
INPUT: Code changes + Project state
OUTPUT: Pass/Fail + Score + Issues

FUNCTION evaluate_quality(changes, project):
  results = {
    safety: evaluate_safety(changes),
    types: evaluate_types(changes),
    lint: evaluate_lint(changes),
    tests: evaluate_tests(changes),
    build: evaluate_build(project),
    security: evaluate_security(changes),
    integration: evaluate_integration(changes, project)
  }

  total_score = weighted_average(results, {
    safety: 0.25,      // Safety is critical
    types: 0.15,
    lint: 0.10,
    tests: 0.20,
    build: 0.15,
    security: 0.10,
    integration: 0.05
  })

  gates_passed = count(results where score >= PASS_THRESHOLD)

  RETURN {
    score: total_score,
    gates_passed: gates_passed,
    total_gates: 7,
    passed: total_score >= 70 AND results.safety.score >= 90,
    details: results,
    critical_issues: filter_issues(results, severity="critical")
  }
```

## ALGORITHM 6: ANTI-FABRICATION VERIFIER

```
INPUT: Agent's technical claim + Source material
OUTPUT: VERIFIED / UNVERIFIED / FABRICATED

FUNCTION verify_claim(claim):
  // Parse the claim
  parsed = parse_technical_claim(claim)

  IF parsed.type == "API":
    // Verify API exists in library
    docs = fetch_library_docs(parsed.library, parsed.version)
    IF parsed.function in docs.functions:
      RETURN VERIFIED({ source: docs.url })
    ELSE:
      RETURN FABRICATED({
        claim: claim,
        reason: "Function not found in library docs"
      })

  IF parsed.type == "IMPORT":
    // Verify import path resolves
    package = resolve_package(parsed.import_path)
    IF package.resolves:
      RETURN VERIFIED({ path: package.resolved_path })
    ELSE:
      RETURN FABRICATED({
        claim: claim,
        reason: "Import path does not resolve"
      })

  IF parsed.type == "CONFIG":
    // Verify config option exists
    docs = fetch_library_docs(parsed.library)
    IF parsed.option in docs.configuration:
      RETURN VERIFIED({ source: docs.url })
    ELSE:
      RETURN UNVERIFIED({
        claim: claim,
        reason: "Cannot verify config option"
      })

  RETURN UNVERIFIED({ claim: claim, reason: "Unknown claim type" })
```

## ALGORITHM 7: ERROR RECOVERY DECISION TREE

```
INPUT: Error + Context + Retry count
OUTPUT: Recovery action

FUNCTION recover_from_error(error, context, retry_count):
  IF retry_count >= 3:
    RETURN { action: "ESCALATE", message: "Max retries exceeded" }

  error_type = classify_error(error)

  SWITCH error_type:
    CASE "COMPILATION":
      RETURN {
        action: "FIX_SYNTAX",
        steps: ["Read error message", "Fix syntax", "Re-compile"]
      }

    CASE "TYPE_ERROR":
      RETURN {
        action: "FIX_TYPES",
        steps: ["Analyze type mismatch", "Add proper types", "Re-check"]
      }

    CASE "TEST_FAILURE":
      RETURN {
        action: "FIX_LOGIC",
        steps: ["Read test failure", "Fix root cause", "Re-run tests"]
      }

    CASE "BUILD_ERROR":
      RETURN {
        action: "FIX_BUILD",
        steps: ["Analyze build logs", "Fix missing deps/assets", "Re-build"]
      }

    CASE "DEPENDENCY_CONFLICT":
      RETURN {
        action: "RESOLVE_DEPS",
        steps: ["Identify conflict", "Find compatible versions", "Re-install"]
      }

    CASE "RUNTIME_ERROR":
      RETURN {
        action: "DEBUG_RUNTIME",
        steps: ["Analyze stack trace", "Fix root cause", "Re-test"]
      }

    CASE "NETWORK_ERROR":
      IF retry_count < 2:
        RETURN { action: "RETRY", delay: "30s" }
      ELSE:
        RETURN { action: "ESCALATE", message: "Persistent network error" }

    DEFAULT:
      RETURN {
        action: "INVESTIGATE",
        steps: ["Read error details", "Search for similar issues", "Report"]
      }
```
