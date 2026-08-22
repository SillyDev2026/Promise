# Promise v1.1.0

A lightweight Roblox Luau Promise module with strict typing, cancellation, retries, event helpers, collection utilities, and a lower-overhead v1.1 core.

## What changed in v1.1

v1.1 focuses on call/setup speed and bug fixing without removing the v1.0.5 API.

Performance work:

- `Promise.resolve()` and `Promise.reject()` build settled Promises directly instead of creating resolver closures just to settle immediately.
- Resolving a Promise with an already-settled Promise adopts its state directly.
- `Promise.all()`, `allPacked()`, `allSettled()`, `race()`, `any()`, and `mapLimit()` set up their internal observers directly instead of creating an extra executor task.
- Collection cancellation no longer creates a temporary cancelled Promise to transfer cancellation.
- `mapLimit()` keeps an O(1) active counter instead of recounting the active table when new jobs launch.
- `Promise.delay()` and `delayValue()` create their timers directly.
- `Promise.timeout()` installs its observer and timer directly.
- `fromEvent()` and `fromEvents()` install signal connections directly.
- Settled callback lists are flushed as one queued batch per Promise instead of one queue closure per observer.
- The microtask queue reuses one queue and drains newly-added work in the same batch, with a budget to avoid an unlimited single flush.
- Empty packed return values reuse an internal immutable empty pack.
- Already-disconnected handles reuse an immutable no-op object.

## Install

Place `Promise.lua` in `ReplicatedStorage` or your package folder.

```lua
local Promise = require(game:GetService("ReplicatedStorage").Promise)
```

The module uses:

```lua
--!strict
--!native
--!optimize 2
```

## Basic

```lua
Promise.new(function(resolve, reject, onCancel)
    local alive = true

    onCancel(function()
        alive = false
    end)

    task.wait(1)

    if alive then
        resolve("Loaded", 200)
    end
end)
:andThen(function(value, code)
    print(value, code)
end)
:catch(warn)
```

`Promise.new()` still runs executors on Roblox's task scheduler, so a yielding executor does not yield the caller that created the Promise.

## Fast settled values

```lua
local ready = Promise.resolve("ready")
local failed = Promise.reject("failed")
```

v1.2 has a shorter internal path for both of these calls.

A settled callback is still delivered through the Promise callback queue:

```lua
local ran = false

Promise.resolve(10):andThen(function()
    ran = true
end)

print(ran) -- false at this point
task.wait()
print(ran) -- true
```

## `Promise.try()` and `Promise.tryNow()`

Use `Promise.try()` when the function may yield or when you want it wrapped through the normal Promise executor path.

```lua
Promise.try(function()
    task.wait()
    return "done"
end)
```

For a non-yielding hot path, v1.2 adds `Promise.tryNow()`:

```lua
local result = Promise.tryNow(function(a, b)
    return a + b
end, 20, 22)

print(result:expect()) -- 42
```

`tryNow()` executes the callback immediately, so use it only when immediate execution is what you want.

## Chaining

```lua
Promise.resolve(5)
:andThen(function(value)
    return Promise.delayValue(0.25, value * 2)
end)
:tap(function(value)
    print("value", value)
end)
:andThenReturn("done")
:andThen(print)
```

Returned Promises flatten automatically.

Also available:

- `andThenCall`
- `andThenReturn`
- `catchCall`
- `catchReturn`
- `tap`
- `tapCatch`
- `Then`
- `Catch`
- `Error`
- `Finally`

## Manual resolvers

```lua
local deferred = Promise.withResolvers()

task.defer(function()
    deferred.resolve("ready")
end)

print(deferred.promise:expect())
```

`Promise.pending()` is the same API.

## Await / unwrap

```lua
local ok, value = Promise.delayValue(1, "Done"):await()

if ok then
    print(value)
end
```

Throw on rejection/cancellation:

```lua
local value = promise:expect()
local same = promise:unwrap()
```

`Expect` and `Unwrap` aliases are also available.

## Non-yielding state inspection

v1.1 adds `isSettled()` and `result()`.

```lua
local promise = Promise.resolve("ready", 200)

print(promise:isSettled())

local status, value, code = promise:result()
print(status, value, code)
```

`result()` never waits. A pending Promise returns `Promise.Status.Pending` with no result values.

Existing helpers remain:

```lua
promise:getStatus()
promise:status()
promise:isPending()
promise:isFulfilled()
promise:isRejected()
promise:isCancelled()
```

## Cancellation

```lua
local token = Promise.newCancellationToken()

local work = Promise.new(function(resolve, reject, onCancel)
    local cancelled = false

    onCancel(function(reason)
        cancelled = true
        print("cancelled", reason)
    end)

    task.wait(5)

    if not cancelled then
        resolve("Finished")
    end
end, token)

token:Cancel("No longer needed")
```

Direct cancellation:

```lua
work:cancel("Stopped")
```

## Collections

```lua
local values = Promise.all({
    Promise.resolve(1),
    Promise.resolve(2),
    Promise.resolve(3),
}):expect()
```

Available:

- `Promise.all()`
- `Promise.allPacked()`
- `Promise.allSettled()`
- `Promise.settleAll()` alias
- `Promise.race()`
- `Promise.first()` alias
- `Promise.any()`
- `Promise.map()`
- `Promise.mapLimit()`
- `Promise.each()`
- `Promise.filter()`

`all`, `mapLimit`, and `each` keep an `.n` logical count for nil slots.

### Limited concurrency

```lua
Promise.mapLimit(ids, 4, function(id)
    return loadPlayer(id)
end)
```

v1.1 no longer scans the active worker table each time it launches another item.

## Timers

```lua
Promise.delay(1):andThen(function(elapsed)
    print(elapsed)
end)

Promise.delayValue(1, "ready", 200):andThen(function(value, code)
    print(value, code)
end)
```

`Promise.after()` aliases `Promise.delay()`.

## Timeout

Static:

```lua
Promise.timeout(request, 3, "Request timed out")
```

Instance:

```lua
request:timeout(3, "Request timed out")
```

Cancel the source when the timeout wins:

```lua
request:timeout(3, "Request timed out", true)
```

The older `timeOut` spelling remains supported.

## Retry

```lua
Promise.retry(function(resolve, reject)
    if math.random() > 0.5 then
        resolve("Success")
    else
        reject("Try again")
    end
end, 5)
```

Also available:

- `retryDelay`
- `retryAsync`
- `retryBackoff`
- `retryUntilSuccess`
- `repeatUntil`

## Events

```lua
Promise.fromSignal(workspace.ChildAdded, function(child)
    return child.Name == "Target"
end):andThen(function(child)
    print(child)
end)
```

`fromEvent()` is the same one-signal helper.

Wait for several signals:

```lua
Promise.fromEvents({
    eventA.Event,
    eventB.Event,
}):andThen(function(results)
    print(results[1][1], results[2][1])
end)
```

v1.2 validates the signal list before connecting and uses direct one-shot connection setup.

## Function wrapping

```lua
local loadAsync = Promise.async(function(id)
    return loadData(id)
end)

loadAsync(123):andThen(print)
```

`Promise.async`, `Promise.wrap`, and `Promise.promisify` refer to the same wrapper API.

## Status constants

```lua
Promise.Status.Pending
Promise.Status.Fulfilled
Promise.Status.Rejected
Promise.Status.Cancelled
```

## Compatibility

v1.1 retains the v1.0.5 surface, including:

- `Promise.new`
- `Promise.defer`
- `Promise.resolve`
- `Promise.reject`
- `Promise.try`
- `Promise.pending`
- `Promise.withResolvers`
- all collection helpers
- retry helpers
- timer helpers
- event helpers
- logging helpers
- Discord embed/webhook helpers
- cancellation tokens
- uppercase method aliases
- `timeOut`

New v1.1 QOL APIs are additive: `tryNow`, `isSettled`, `result`, `unwrap`, `Unwrap`, `async`, `first`, and `settleAll`.

## Tests

Put `Promise.lua` in `ReplicatedStorage`, then run:

- `tests/PromiseTests.server.lua` from `ServerScriptService`
- `benchmarks/Benchmark.server.lua` from `ServerScriptService`

The benchmark prints construction/setup timings for several hot paths. Run it in the same Studio environment when comparing versions.
