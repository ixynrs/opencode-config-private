#requires -Version 7
<#
  Runtime contract checks for the global orchestrator and leaf agent policies.

  Evidence source: the real OpenCode V2 API through the installed `opencode` CLI.
  These checks evaluate the published ordered permission rules from resolved
  agent data. They are policy conformance checks. They do not prove the runtime
  permission engine or model behavior.

  No mock is used. No production dependency is added.
  Matching uses only documented whole-value * and ? wildcards.
  Windows path separators are normalized and matching is case-insensitive.
#>
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$script:Failures = 0
$script:Checks = 0

function Write-Result {
    param([string]$Name, [bool]$Ok)
    $script:Checks++
    if ($Ok) {
        Write-Host ("PASS  {0}" -f $Name)
    }
    else {
        Write-Host ("FAIL  {0}" -f $Name)
        $script:Failures++
    }
}

function Invoke-ApiGet {
    param([string]$Path)
    $output = & opencode api get $Path 2>&1 | Out-String
    $code = $LASTEXITCODE
    if ($code -ne 0) {
        throw "Native command failed: opencode api get $Path (exit $code). $output"
    }
    try {
        return ($output | ConvertFrom-Json)
    }
    catch {
        throw "opencode api get $Path returned invalid JSON: $($_.Exception.Message)"
    }
}

function Get-Agents {
    $response = Invoke-ApiGet '/api/agent'
    if ($null -eq $response) { throw 'Agent catalog response is empty.' }
    if (-not ($response.PSObject.Properties.Name -contains 'data')) {
        throw 'Agent catalog response is missing the data field.'
    }
    return $response.data
}

function Get-AgentState {
    param([string]$Id)
    $output = & opencode api get "/api/agent/$Id" 2>&1 | Out-String
    if ($LASTEXITCODE -ne 0) { return $null }
    try { $parsed = $output | ConvertFrom-Json }
    catch { return $null }
    if ($null -eq $parsed) { return $null }
    if (-not ($parsed.PSObject.Properties.Name -contains 'data')) { return $null }
    return $parsed.data
}

function Normalize-Value {
    param([string]$Value)
    if ([string]::IsNullOrEmpty($Value)) { return '' }
    return ($Value -replace '\\', '/').ToLowerInvariant()
}

function ConvertTo-WildcardRegex {
    param([string]$Pattern)
    $escaped = [regex]::Escape($Pattern)
    $escaped = $escaped.Replace('\*', '.*').Replace('\?', '.')
    return ('^{0}$' -f $escaped)
}

function Test-Wildcard {
    param([string]$Pattern, [string]$Value)
    $p = Normalize-Value $Pattern
    $v = Normalize-Value $Value
    # A shell pattern ending in " *" also matches the command without arguments.
    if ($p.EndsWith(' *')) {
        $bare = $p.Substring(0, $p.Length - 2)
        if ($v -eq $bare) { return $true }
    }
    return [regex]::IsMatch($v, (ConvertTo-WildcardRegex $p))
}

function Resolve-Effect {
    param($Rules, [string]$Action, [string]$Resource)
    # The last matching rule wins. If no rule matches, OpenCode uses ask.
    $effect = 'ask'
    foreach ($rule in $Rules) {
        if ((Test-Wildcard $rule.action $Action) -and (Test-Wildcard $rule.resource $Resource)) {
            $effect = $rule.effect
        }
    }
    return $effect
}

function Assert-Policy {
    param([string]$AgentId, $Rules, [string]$Action, [string]$Resource, [string]$Expected)
    $actual = Resolve-Effect $Rules $Action $Resource
    $label = "[{0}] {1} '{2}' => {3}" -f $AgentId, $Action, $Resource, $Expected
    Write-Result $label ($actual -eq $Expected)
    if ($actual -ne $Expected) { Write-Host ("      actual: {0}" -f $actual) }
}

function Assert-Model {
    param([string]$AgentId, $State, [string]$Expected)
    $actual = '<none>'
    if (($State.PSObject.Properties.Name -contains 'model') -and $null -ne $State.model) {
        $actual = ('{0}/{1}' -f $State.model.providerID, $State.model.id)
    }
    Write-Result "[$AgentId] model is $Expected" ($actual -eq $Expected)
    if ($actual -ne $Expected) { Write-Host ("      actual: {0}" -f $actual) }
}

# ---------------------------------------------------------------------------
# Independently specified policy cases.
# ---------------------------------------------------------------------------

$orchestratorCases = @(
    @{ a = 'read'; r = 'C:/Users/raffy/codes/ixynrs/lift-core/app/Models/User.php'; e = 'allow' },
    @{ a = 'read'; r = '.env'; e = 'deny' },
    @{ a = 'read'; r = '.env.local'; e = 'deny' },
    @{ a = 'read'; r = '.env.example'; e = 'allow' },
    @{ a = 'glob'; r = '**/*.ts'; e = 'allow' },
    @{ a = 'grep'; r = 'TenantModel'; e = 'allow' },
    @{ a = 'question'; r = '*'; e = 'allow' },
    @{ a = 'skill'; r = 'opencode'; e = 'allow' },
    @{ a = 'execute'; r = '*'; e = 'allow' },
    @{ a = 'webfetch'; r = 'https://opencode.ai/v2/docs/'; e = 'allow' },
    @{ a = 'websearch'; r = 'opencode v2 agents'; e = 'allow' },
    @{ a = 'edit'; r = 'C:/Users/raffy/codes/ixynrs/lift-core/app/Foo.php'; e = 'deny' },
    @{ a = 'subagent'; r = 'explore'; e = 'allow' },
    @{ a = 'subagent'; r = 'web-researcher'; e = 'allow' },
    @{ a = 'subagent'; r = 'executor'; e = 'allow' },
    @{ a = 'subagent'; r = 'code-reviewer'; e = 'allow' },
    @{ a = 'subagent'; r = 'general'; e = 'deny' },
    @{ a = 'subagent'; r = 'build'; e = 'deny' },
    @{ a = 'external_directory'; r = 'C:/Users/raffy/.config/opencode/agents/orchestrator.md'; e = 'allow' },
    @{ a = 'external_directory'; r = 'C:/Users/raffy/AppData/Local/Temp/opencode/run/out.txt'; e = 'allow' },
    @{ a = 'external_directory'; r = 'C:/Users/Public/other/file.txt'; e = 'ask' },
    @{ a = 'shell'; r = 'git status'; e = 'allow' },
    @{ a = 'shell'; r = 'git status --short'; e = 'allow' },
    @{ a = 'shell'; r = 'git diff --stat'; e = 'allow' },
    @{ a = 'shell'; r = 'git log -1'; e = 'allow' },
    @{ a = 'shell'; r = 'git ls-files'; e = 'allow' },
    @{ a = 'shell'; r = 'git push origin main'; e = 'deny' },
    @{ a = 'shell'; r = 'git commit -m x'; e = 'deny' },
    @{ a = 'shell'; r = 'git rebase main'; e = 'deny' },
    @{ a = 'shell'; r = 'npm run build'; e = 'deny' },
    @{ a = 'shell'; r = 'rm -rf /'; e = 'deny' },
    @{ a = 'context7_resolve-library-id'; r = '*'; e = 'allow' },
    @{ a = 'context7_query-docs'; r = '*'; e = 'allow' },
    @{ a = 'laravel-boost_application-info'; r = '*'; e = 'allow' },
    @{ a = 'laravel-boost_search-docs'; r = '*'; e = 'allow' },
    @{ a = 'laravel-boost_get-absolute-url'; r = '*'; e = 'allow' },
    @{ a = 'laravel-boost_database-connections'; r = '*'; e = 'allow' },
    @{ a = 'laravel-boost_database-schema'; r = '*'; e = 'ask' },
    @{ a = 'laravel-boost_database-query'; r = '*'; e = 'ask' },
    @{ a = 'laravel-boost_browser-logs'; r = '*'; e = 'ask' },
    @{ a = 'laravel-boost_last-error'; r = '*'; e = 'ask' },
    @{ a = 'laravel-boost_read-log-entries'; r = '*'; e = 'ask' },
    @{ a = 'playwright_browser_navigate'; r = '*'; e = 'ask' },
    @{ a = 'playwright_browser_click'; r = '*'; e = 'ask' },
    @{ a = 'drawio_search_shapes'; r = '*'; e = 'deny' },
    @{ a = 'ppt_list_presentations'; r = '*'; e = 'deny' }
)

$executorCases = @(
    @{ a = 'edit'; r = 'C:/Users/raffy/codes/ixynrs/lift-core/app/Foo.php'; e = 'allow' },
    @{ a = 'subagent'; r = 'executor'; e = 'deny' },
    @{ a = 'subagent'; r = 'explore'; e = 'deny' },
    @{ a = 'shell'; r = 'git status'; e = 'allow' },
    @{ a = 'shell'; r = 'git diff --stat'; e = 'allow' },
    @{ a = 'shell'; r = 'opencode reload'; e = 'allow' },
    @{ a = 'shell'; r = 'opencode api get /api/agent'; e = 'allow' },
    @{ a = 'shell'; r = 'opencode api get /api/agent/executor'; e = 'allow' },
    @{ a = 'shell'; r = 'php artisan test'; e = 'ask' },
    @{ a = 'shell'; r = 'unknown-tool --flag'; e = 'ask' },
    @{ a = 'shell'; r = 'git commit -m x'; e = 'deny' },
    @{ a = 'shell'; r = 'git rebase main'; e = 'deny' },
    @{ a = 'shell'; r = 'git push origin main'; e = 'deny' },
    @{ a = 'shell'; r = 'gh pr create'; e = 'deny' },
    @{ a = 'shell'; r = 'npm run build'; e = 'deny' },
    @{ a = 'shell'; r = 'npx vite build'; e = 'deny' },
    @{ a = 'shell'; r = './vendor/bin/pint'; e = 'deny' },
    @{ a = 'shell'; r = 'php artisan migrate:fresh'; e = 'deny' },
    @{ a = 'shell'; r = 'composer run setup'; e = 'deny' }
)

$reviewerCases = @(
    @{ a = 'read'; r = 'app/Foo.php'; e = 'allow' },
    @{ a = 'glob'; r = '**/*.php'; e = 'allow' },
    @{ a = 'grep'; r = 'foo'; e = 'allow' },
    @{ a = 'skill'; r = 'opencode'; e = 'allow' },
    @{ a = 'webfetch'; r = 'https://example.com'; e = 'allow' },
    @{ a = 'edit'; r = 'C:/Users/raffy/codes/ixynrs/lift-core/app/Foo.php'; e = 'deny' },
    @{ a = 'shell'; r = 'git diff --stat'; e = 'allow' },
    @{ a = 'shell'; r = 'git log -1'; e = 'allow' },
    @{ a = 'shell'; r = 'git commit -m x'; e = 'deny' },
    @{ a = 'shell'; r = 'npm run build'; e = 'deny' },
    @{ a = 'subagent'; r = 'executor'; e = 'deny' },
    @{ a = 'context7_query-docs'; r = '*'; e = 'allow' },
    @{ a = 'playwright_browser_navigate'; r = '*'; e = 'deny' },
    @{ a = 'ppt_list_presentations'; r = '*'; e = 'deny' },
    @{ a = 'drawio_search_shapes'; r = '*'; e = 'deny' }
)

$researcherCases = @(
    @{ a = 'read'; r = 'app/Foo.php'; e = 'allow' },
    @{ a = 'glob'; r = '**/*.php'; e = 'allow' },
    @{ a = 'grep'; r = 'foo'; e = 'allow' },
    @{ a = 'skill'; r = 'opencode'; e = 'allow' },
    @{ a = 'execute'; r = '*'; e = 'allow' },
    @{ a = 'webfetch'; r = 'https://example.com'; e = 'allow' },
    @{ a = 'websearch'; r = 'opencode v2'; e = 'allow' },
    @{ a = 'edit'; r = 'app/Foo.php'; e = 'deny' },
    @{ a = 'shell'; r = 'git status'; e = 'deny' },
    @{ a = 'subagent'; r = 'explore'; e = 'deny' },
    @{ a = 'context7_query-docs'; r = '*'; e = 'allow' },
    @{ a = 'playwright_browser_navigate'; r = '*'; e = 'deny' }
)

$exploreCases = @(
    @{ a = 'read'; r = 'app/Foo.php'; e = 'allow' },
    @{ a = 'glob'; r = '**/*.ts'; e = 'allow' },
    @{ a = 'grep'; r = 'foo'; e = 'allow' },
    @{ a = 'webfetch'; r = 'https://example.com'; e = 'allow' },
    @{ a = 'websearch'; r = 'opencode'; e = 'allow' },
    @{ a = 'shell'; r = 'git status'; e = 'deny' },
    @{ a = 'edit'; r = 'app/Foo.php'; e = 'deny' },
    @{ a = 'subagent'; r = 'executor'; e = 'deny' }
)

# ---------------------------------------------------------------------------
# Run.
# ---------------------------------------------------------------------------

Write-Host 'OpenCode orchestrator contract checks (policy conformance)'
Write-Host 'Evidence source: native API via the opencode CLI'
Write-Host ('-' * 64)

$agents = Get-Agents
$byId = @{}
foreach ($agent in $agents) { $byId[$agent.id] = $agent }

$orchestrator = $byId['orchestrator']
Write-Result 'catalog contains orchestrator' ($null -ne $orchestrator)
if ($null -ne $orchestrator) {
    Write-Result '[orchestrator] mode is primary' ($orchestrator.mode -eq 'primary')
    $hasModel = ($orchestrator.PSObject.Properties.Name -contains 'model') -and ($null -ne $orchestrator.model)
    Write-Result '[orchestrator] model omitted, retains session selection' (-not $hasModel)
    foreach ($case in $orchestratorCases) {
        Assert-Policy 'orchestrator' $orchestrator.permissions $case.a $case.r $case.e
    }
}
else {
    Write-Host 'SKIP  orchestrator policy cases (agent missing)'
}

$executor = $byId['executor']
Write-Result 'catalog contains executor' ($null -ne $executor)
if ($null -ne $executor) {
    Assert-Model 'executor' $executor 'opencode-go/deepseek-v4.1-flash'
    Write-Result '[executor] mode is subagent' ($executor.mode -eq 'subagent')
    foreach ($case in $executorCases) {
        Assert-Policy 'executor' $executor.permissions $case.a $case.r $case.e
    }
}

$reviewer = $byId['code-reviewer']
Write-Result 'catalog contains code-reviewer' ($null -ne $reviewer)
if ($null -ne $reviewer) {
    Assert-Model 'code-reviewer' $reviewer 'opencode-go/deepseek-v4.1-flash'
    Write-Result '[code-reviewer] mode is subagent' ($reviewer.mode -eq 'subagent')
    foreach ($case in $reviewerCases) {
        Assert-Policy 'code-reviewer' $reviewer.permissions $case.a $case.r $case.e
    }
}

$researcher = $byId['web-researcher']
Write-Result 'catalog contains web-researcher' ($null -ne $researcher)
if ($null -ne $researcher) {
    Assert-Model 'web-researcher' $researcher 'opencode-go/muse-spark-1.3-contributor'
    foreach ($case in $researcherCases) {
        Assert-Policy 'web-researcher' $researcher.permissions $case.a $case.r $case.e
    }
}

$explore = $byId['explore']
Write-Result 'catalog contains explore' ($null -ne $explore)
if ($null -ne $explore) {
    Assert-Model 'explore' $explore 'opencode-go/muse-spark-1.3-contributor'
    foreach ($case in $exploreCases) {
        Assert-Policy 'explore' $explore.permissions $case.a $case.r $case.e
    }
}

Write-Host ('-' * 64)
Write-Host ("Checks: {0}  Failures: {1}" -f $script:Checks, $script:Failures)

if ($script:Failures -gt 0) { exit 1 }
exit 0
