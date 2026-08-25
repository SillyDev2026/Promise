# Promise v1.2.0

A lightweight, typed Promise library for Roblox Luau focused on **low overhead, predictable scheduling, cancellation, retries, concurrency utilities, events, and ergonomic async workflows**.

Promise v1.2.0 keeps the existing API while improving several hot paths used for settled values, collections, timers, events, and synchronous function wrapping.

---

## Features

* Promise chaining with automatic Promise flattening
* Multiple return value support
* Cancellation and cancellation tokens
* Fast settled Promise creation
* Awaiting, unwrapping, and non-yielding state inspection
* Collection utilities
* Limited-concurrency mapping
* Retry and exponential backoff helpers
* Delays and timeouts
* Roblox signal helpers
* Function wrapping / promisification
* Deferred/manual resolvers
* Discord webhook helpers
* Uppercase compatibility aliases
* Optimized internal microtask queue
* Luau type definitions
* `--!native`
* `--!optimize 2`

---

## Installation

Place `Promise.lua` somewhere accessible to both sides that need it, such as `ReplicatedStorage`:

```text
ReplicatedStorage
└── Promise
```

Then require it:

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Promise = require(ReplicatedStorage.Promise)
```

Check the installed version:

```lua
print(Promise.VERSION)
print(Promise.Version())

Promise.print()
```

---

# Quick Start

```lua
Promise.new(function(resolve, reject, onCancel)
	local alive = true

	onCancel(function(reason)
		alive = false
		print("Cancelled:", reason)
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

`Promise.new()` schedules its executor through Roblox's task scheduler.

This means a yielding executor does **not** yield the code that created the Promise.

---

# What's New in v1.2.0

v1.2.0 focuses primarily on reducing setup overhead while preserving the existing Promise API.

### Faster settled Promises

`Promise.resolve()` and `Promise.reject()` construct settled Promises directly.

```lua
local ready = Promise.resolve("Ready")
local failed = Promise.reject("Failed")
```

Passing an existing Promise through `Promise.resolve()` also returns that Promise directly:

```lua
local original = Promise.resolve(100)
local same = Promise.resolve(original)

print(original == same) -- true
```

### Faster synchronous wrapping

For callbacks that do not yield, `Promise.tryNow()` avoids the normal scheduled executor path.

```lua
local result = Promise.tryNow(function(a, b)
	return a + b
end, 20, 22)

print(result:expect()) -- 42
```

Use `Promise.try()` when normal Promise scheduling is preferred or when the callback may yield.

### Faster collection setup

Collection helpers install their internal observers directly rather than creating unnecessary executor tasks.

This applies to hot paths such as:

```lua
Promise.all(...)
Promise.allPacked(...)
Promise.allSettled(...)
Promise.race(...)
Promise.any(...)
Promise.mapLimit(...)
```

### Improved `mapLimit()`

`mapLimit()` maintains an O(1) active worker counter instead of repeatedly counting its active worker table.

### Improved timers

Timers are created directly for:

```lua
Promise.delay(...)
Promise.delayValue(...)
Promise.timeout(...)
```

### Improved events

`fromEvent()` and `fromEvents()` install their Roblox signal connections directly.

`fromEvents()` also validates every signal before connecting.

### Improved callback scheduling

Settled callback lists are processed as a queued batch rather than creating a separate queue closure for every observer.

The internal microtask queue is reused and can process newly-added work during the same drain while still enforcing a budget to prevent an unlimited single flush.

### Reduced temporary allocations

v1.2.0 also reuses internal immutable values for common cases such as:

* empty packed return values
* already-disconnected handles

---

# Promise States

Every Promise has one of four states:

```lua
Promise.Status.Pending
Promise.Status.Fulfilled
Promise.Status.Rejected
Promise.Status.Cancelled
```

Example:

```lua
local promise = Promise.resolve("Ready")

print(promise:getStatus())
print(promise:isFulfilled())
```

---

# Creating Promises

## `Promise.new()`

```lua
local promise = Promise.new(function(resolve, reject, onCancel)
	local success = true

	if success then
		resolve("Done")
	else
		reject("Failed")
	end
end)
```

The executor receives:

```lua
resolve(...)
reject(...)
onCancel(callback)
```

---

## `Promise.defer()`

Works like `Promise.new()`, but schedules the executor using the deferred scheduler path.

```lua
local promise = Promise.defer(function(resolve)
	resolve("Deferred")
end)
```

---

# Settled Promises

## Resolve

```lua
local promise = Promise.resolve("Ready")
```

Multiple values are supported:

```lua
local promise = Promise.resolve("Ready", 200, true)

local text, code, cached = promise:expect()
```

## Reject

```lua
local promise = Promise.reject("Something went wrong")
```

---

# Callback Scheduling

Even when a Promise is already settled, chained callbacks are delivered through the Promise callback queue.

```lua
local ran = false

Promise.resolve(10):andThen(function()
	ran = true
end)

print(ran) -- false

task.wait()

print(ran) -- true
```

This keeps chaining behavior predictable between pending and already-settled Promises.

---

# `Promise.try()`

Wrap a function in a normal Promise executor.

```lua
Promise.try(function()
	task.wait()

	return "Done"
end)
	:andThen(print)
	:catch(warn)
```

Errors become Promise rejections automatically.

```lua
Promise.try(function()
	error("Something failed")
end):catch(warn)
```

---

# `Promise.tryNow()`

Execute a callback immediately and convert its result into a settled Promise.

```lua
local promise = Promise.tryNow(function(a, b)
	return a * b
end, 6, 7)

print(promise:expect()) -- 42
```

If the function errors:

```lua
Promise.tryNow(function()
	error("Failure")
end):catch(warn)
```

Use `tryNow()` for **non-yielding hot paths** where immediate execution is desired.

---

# Chaining

```lua
Promise.resolve(5)
	:andThen(function(value)
		return value * 2
	end)
	:andThen(function(value)
		print(value) -- 10
	end)
	:catch(warn)
```

Returned Promises are flattened automatically:

```lua
Promise.resolve(5)
	:andThen(function(value)
		return Promise.delayValue(0.25, value * 2)
	end)
	:andThen(print)
```

---

# Chaining Helpers

## `andThenCall()`

Call a function with predefined arguments after fulfillment.

```lua
Promise.resolve()
	:andThenCall(print, "Hello", "World")
```

## `andThenReturn()`

Replace the fulfilled value.

```lua
Promise.resolve(123)
	:andThenReturn("Done")
	:andThen(print)
```

## `catchCall()`

```lua
Promise.reject("Failed")
	:catchCall(warn, "Request failed")
```

## `catchReturn()`

```lua
local value = Promise.reject("Failed")
	:catchReturn("Fallback")
	:expect()

print(value) -- Fallback
```

---

# Tap

Run a side effect without replacing the original fulfilled values.

```lua
Promise.resolve(100)
	:tap(function(value)
		print("Received:", value)
	end)
	:andThen(function(value)
		print(value) -- 100
	end)
```

For rejected Promises:

```lua
Promise.reject("Failure")
	:tapCatch(function(reason)
		warn(reason)
	end)
	:catch(function()
		return "Recovered"
	end)
```

---

# Finalization

```lua
Promise.resolve("Done")
	:finally(function()
		print("Cleanup")
	end)
```

`finally()` can also return a Promise.

```lua
promise:finally(function()
	return saveCleanupData()
end)
```

Alias:

```lua
promise:Finally(...)
```

---

# Manual Resolvers

Create a pending Promise without an executor:

```lua
local deferred = Promise.withResolvers()

task.defer(function()
	deferred.resolve("Ready")
end)

print(deferred.promise:expect())
```

You receive:

```lua
deferred.promise
deferred.resolve(...)
deferred.reject(...)
deferred.cancel(...)
```

`Promise.pending()` provides the same API.

```lua
local deferred = Promise.pending()
```

---

# Awaiting

## `await()`

```lua
local ok, value = Promise.delayValue(1, "Done"):await()

if ok then
	print(value)
else
	warn(value)
end
```

`await()` returns:

```text
true,  ...fulfilledValues
false, ...rejectionOrCancellationValues
```

Alias:

```lua
promise:Await()
```

---

## `awaitStatus()`

Return the exact Promise status alongside its values.

```lua
local status, value = promise:awaitStatus()

if status == Promise.Status.Fulfilled then
	print(value)
end
```

Alias:

```lua
promise:AwaitStatus()
```

---

# Expect / Unwrap

Throw if the Promise rejects or is cancelled:

```lua
local value = promise:expect()
```

Equivalent aliases:

```lua
promise:Expect()
promise:unwrap()
promise:Unwrap()
```

---

# Non-Yielding State Inspection

## `isSettled()`

```lua
if promise:isSettled() then
	print("Finished")
end
```

## `result()`

Inspect the current state without yielding:

```lua
local promise = Promise.resolve("Ready", 200)

local status, value, code = promise:result()

print(status)
print(value)
print(code)
```

A pending Promise returns:

```lua
Promise.Status.Pending
```

without waiting for completion.

Other state helpers:

```lua
promise:getStatus()
promise:status()

promise:isPending()
promise:isFulfilled()
promise:isRejected()
promise:isCancelled()
promise:isSettled()
```

---

# `now()`

Convert the Promise's **current** state into an immediately-settled Promise.

```lua
local current = promise:now()
```

If the original Promise is still pending, the returned Promise rejects with:

```text
Promise is not resolved
```

This does not wait for the source Promise.

---

# Cancellation

Promises support direct cancellation.

```lua
local work = Promise.new(function(resolve, reject, onCancel)
	local cancelled = false

	onCancel(function(reason)
		cancelled = true
		print("Cancelled:", reason)
	end)

	task.wait(5)

	if not cancelled then
		resolve("Finished")
	end
end)

work:cancel("Stopped")
```

Alias:

```lua
work:Cancel("Stopped")
```

---

# Cancellation Tokens

A cancellation token can control Promise work externally.

```lua
local token = Promise.newCancellationToken()

local work = Promise.new(function(resolve, reject, onCancel)
	local cancelled = false

	onCancel(function(reason)
		cancelled = true
		print("Cancelled:", reason)
	end)

	task.wait(5)

	if not cancelled then
		resolve("Finished")
	end
end, token)

token:Cancel("No longer needed")
```

Token methods:

```lua
token:IsCancelled()
token:GetReason()
token:OnCancel(callback)
token:Cancel(reason)
token:ThrowIfCancelled()
token:Destroy()
```

Lowercase aliases are also available:

```lua
token:isCancelled()
token:getReason()
token:onCancel(callback)
token:cancel(reason)
```

---

# Collections

Promise provides helpers for coordinating groups of asynchronous operations.

## `Promise.all()`

Wait for every Promise.

```lua
local values = Promise.all({
	Promise.resolve(1),
	Promise.resolve(2),
	Promise.resolve(3),
}):expect()

print(values[1], values[2], values[3])
```

Rejects when one input rejects and cancels when one input cancellation wins the collection.

---

## `Promise.allPacked()`

Preserves all returned values from each input Promise.

```lua
local values = Promise.allPacked({
	Promise.resolve("A", 1),
	Promise.resolve("B", 2),
}):expect()

print(values[1][1], values[1][2])
print(values[2][1], values[2][2])
```

---

## `Promise.allSettled()`

Wait for every input regardless of fulfillment, rejection, or cancellation.

```lua
local results = Promise.allSettled({
	Promise.resolve("A"),
	Promise.reject("B"),
}):expect()

for _, result in results do
	print(result.status)
end
```

Alias:

```lua
Promise.settleAll(...)
```

---

## `Promise.race()`

Settle when the first input settles.

```lua
Promise.race({
	Promise.delayValue(1, "Slow"),
	Promise.delayValue(0.1, "Fast"),
}):andThen(print)
```

Alias:

```lua
Promise.first(...)
```

---

## `Promise.any()`

Resolve when the first input fulfills.

```lua
Promise.any({
	Promise.reject("Failed A"),
	Promise.delayValue(0.2, "Success"),
	Promise.reject("Failed B"),
}):andThen(print)
```

If every input fails, the Promise rejects with the collected reasons.

---

# Mapping

## `Promise.map()`

```lua
Promise.map({ 1, 2, 3 }, function(value)
	return Promise.resolve(value * 2)
end):andThen(function(results)
	print(results[1], results[2], results[3])
end)
```

---

## `Promise.mapLimit()`

Limit how many mapped operations may run at once.

```lua
Promise.mapLimit(playerIds, 4, function(userId)
	return loadPlayer(userId)
end)
```

This is useful for:

* DataStore operations
* HTTP requests
* asset loading
* rate-limited APIs
* expensive parallel work

v1.2.0 uses an O(1) active worker counter for scheduling additional jobs.

---

## `Promise.each()`

Process values sequentially.

```lua
Promise.each(values, function(value, index)
	print(index, value)

	return processValue(value)
end)
```

---

## `Promise.filter()`

Asynchronously filter a collection.

```lua
Promise.filter(players, function(player)
	return checkPlayerAsync(player)
end):andThen(function(filtered)
	print(filtered)
end)
```

---

## Nil Slot Preservation

Collection results such as `all()`, `mapLimit()`, and `each()` maintain an `.n` logical count where appropriate.

```lua
local values = Promise.all({
	Promise.resolve("A"),
	Promise.resolve(nil),
	Promise.resolve("C"),
}):expect()

print(values.n)
```

This allows logical lengths to survive nil values.

---

# Timers

## `Promise.delay()`

Resolve after a delay.

```lua
Promise.delay(1):andThen(function(elapsed)
	print("Elapsed:", elapsed)
end)
```

`Promise.delay()` resolves with the measured elapsed time.

Alias:

```lua
Promise.after(1)
```

---

## `Promise.delayValue()`

Resolve with custom values after a delay.

```lua
Promise.delayValue(1, "Ready", 200)
	:andThen(function(value, code)
		print(value, code)
	end)
```

---

## `Promise.never()`

Create a Promise that never settles unless externally cancelled.

```lua
local promise = Promise.never()
```

---

# Timeout

Wrap a Promise with a timeout.

## Static

```lua
Promise.timeout(request, 3, "Request timed out")
```

## Instance

```lua
request:timeout(3, "Request timed out")
```

## Cancel the source

```lua
request:timeout(
	3,
	"Request timed out",
	true
)
```

When `cancelSource` is `true`, the original source Promise is cancelled if the timeout wins.

Compatibility aliases remain available:

```lua
Promise.timeOut(...)
promise:timeOut(...)
promise:withTimeout(...)
```

---

# Retry

## Basic Retry

```lua
Promise.retry(function(resolve, reject)
	if math.random() > 0.5 then
		resolve("Success")
	else
		reject("Try again")
	end
end, 5)
```

---

## Retry With Delay

```lua
Promise.retryDelay(function(resolve, reject)
	request(resolve, reject)
end, 5, 0.5)
```

---

## Async Retry

```lua
Promise.retryAsync(function(resolve, reject)
	request(resolve, reject)
end)
```

---

## Exponential Backoff

```lua
Promise.retryBackoff(
	function(resolve, reject)
		request(resolve, reject)
	end,
	5,
	0.25,
	5
)
```

The retry delay increases exponentially until reaching the maximum delay.

---

## Additional Retry Helpers

```lua
Promise.retryUntilSuccess(...)
Promise.repeatUntil(...)
```

---

# Roblox Events

## `Promise.fromEvent()`

Wait for a Roblox signal.

```lua
Promise.fromEvent(workspace.ChildAdded)
	:andThen(function(child)
		print(child)
	end)
```

An optional predicate can filter events:

```lua
Promise.fromEvent(workspace.ChildAdded, function(child)
	return child.Name == "Target"
end):andThen(function(child)
	print("Found:", child)
end)
```

---

## `Promise.fromSignal()`

Alias for `fromEvent()`:

```lua
Promise.fromSignal(workspace.ChildAdded, function(child)
	return child.Name == "Target"
end)
```

---

## `Promise.fromEvents()`

Wait for multiple signals.

```lua
Promise.fromEvents({
	eventA.Event,
	eventB.Event,
}):andThen(function(results)
	print(results[1][1])
	print(results[2][1])
end)
```

Each result entry contains the packed arguments from its corresponding event.

v1.2.0 validates the complete signal list before creating connections.

---

# Function Wrapping

Turn a normal function into a Promise-returning function.

```lua
local loadAsync = Promise.async(function(userId)
	return loadData(userId)
end)

loadAsync(123)
	:andThen(print)
	:catch(warn)
```

The following names refer to the same wrapping API:

```lua
Promise.async
Promise.wrap
Promise.promisify
```

Example:

```lua
local divide = Promise.wrap(function(a, b)
	return a / b
end)

divide(10, 2):andThen(print)
```

---

# Promise Detection

Check whether a value is a Promise created by this module:

```lua
if Promise.is(value) then
	print("Promise")
end
```

Alias:

```lua
Promise.isPromise(value)
```

---

# Resume

Convert a thread into a Promise-based operation:

```lua
Promise.resume(thread)
```

---

# Logging Helpers

The module also includes Promise-based logging helpers.

```lua
Promise.LogMessage("Info", "Server started")
```

---

# Discord Helpers

## Create an Embed

```lua
Promise.CreateEmbed({
	title = "Server Started",
	description = "The server is now online.",
	color = 0x57F287,
}):andThen(function(embed)
	print(embed)
end)
```

Supported embed fields include:

```lua
{
	title = "...",
	description = "...",
	url = "...",
	color = 0xFFFFFF,

	fields = {
		{
			name = "Players",
			value = "10",
			inline = true,
		},
	},

	footer = {},
	author = {},
	thumbnail = {},
	image = {},
	timestamp = "...",
}
```

---

## Send to Discord

```lua
Promise.sendToDiscord(WEBHOOK_URL, {
	content = "Hello from Roblox!",
})
	:andThen(function(response)
		print(response)
	end)
	:catch(warn)
```

`HttpService` must be enabled for HTTP requests.

---

# API Reference

## Creation

```lua
Promise.new(executor, token?)
Promise.defer(executor, token?)

Promise.resolve(...)
Promise.reject(...)

Promise.try(callback, ...)
Promise.tryNow(callback, ...)

Promise.pending()
Promise.withResolvers()

Promise.never()
```

## Chaining

```lua
promise:andThen(...)
promise:catch(...)
promise:finally(...)

promise:tap(...)
promise:tapCatch(...)

promise:andThenCall(...)
promise:andThenReturn(...)

promise:catchCall(...)
promise:catchReturn(...)
```

## State

```lua
promise:getStatus()
promise:status()

promise:isPending()
promise:isFulfilled()
promise:isRejected()
promise:isCancelled()
promise:isSettled()

promise:result()
promise:now()
```

## Awaiting

```lua
promise:await()
promise:awaitStatus()

promise:expect()
promise:unwrap()
```

## Cancellation

```lua
promise:cancel(reason?)
promise:onCancel(callback)

Promise.newCancellationToken()
```

## Collections

```lua
Promise.all(values)
Promise.allPacked(values)
Promise.allSettled(values)
Promise.settleAll(values)

Promise.race(values)
Promise.first(values)
Promise.any(values)

Promise.map(values, mapper)
Promise.mapLimit(values, concurrency, mapper)
Promise.each(values, callback)
Promise.filter(values, predicate)
```

## Timers

```lua
Promise.delay(seconds)
Promise.after(seconds)
Promise.delayValue(seconds, ...)
Promise.timeout(value, seconds, reason?, cancelSource?)
```

## Retry

```lua
Promise.retry(executor, retries)
Promise.retryDelay(executor, retries, delaySeconds)
Promise.retryAsync(executor, retries?, delaySeconds?)
Promise.retryBackoff(executor, retries?, baseDelay?, maxDelay?)

Promise.retryUntilSuccess(...)
Promise.repeatUntil(...)
```

## Events

```lua
Promise.fromEvent(signal, predicate?)
Promise.fromSignal(signal, predicate?)
Promise.fromEvents(signals)
```

## Wrapping

```lua
Promise.wrap(func)
Promise.promisify(func)
Promise.async(func)
```

## Utilities

```lua
Promise.is(value)
Promise.isPromise(value)

Promise.resume(thread)

Promise.Version()
Promise.print()
```

## Discord / Logging

```lua
Promise.LogMessage(level, message)
Promise.CreateEmbed(embed)
Promise.sendToDiscord(url, data, contentType?)
```

---

# Method Aliases

Several compatibility aliases are available:

| Primary              | Alias                                |
| -------------------- | ------------------------------------ |
| `andThen`            | `Then`                               |
| `catch`              | `Catch`, `Error`                     |
| `finally`            | `Finally`                            |
| `cancel`             | `Cancel`                             |
| `await`              | `Await`                              |
| `awaitStatus`        | `AwaitStatus`                        |
| `expect`             | `Expect`                             |
| `unwrap`             | `Unwrap`                             |
| `timeout`            | `timeOut`, `withTimeout`             |
| `Promise.race`       | `Promise.first`                      |
| `Promise.allSettled` | `Promise.settleAll`                  |
| `Promise.wrap`       | `Promise.promisify`, `Promise.async` |
| `Promise.delay`      | `Promise.after`                      |
| `Promise.fromEvent`  | `Promise.fromSignal`                 |

---

# Performance Design

Promise v1.2.0 is designed to avoid unnecessary scheduler work and temporary allocations on common paths.

Important optimizations include:

* direct construction of fulfilled and rejected Promises
* existing Promises returned directly from `Promise.resolve()`
* direct observer setup for collection helpers
* direct timer creation
* direct Roblox signal connection setup
* batched callback flushing
* reusable internal microtask queue
* bounded microtask draining
* O(1) active worker tracking in `mapLimit()`
* reusable immutable empty value packs
* reusable disconnected handles
* reduced temporary Promise creation during collection cancellation

These optimizations primarily target **Promise creation and setup overhead** rather than the execution time of the asynchronous work itself.

---

# Compatibility

v1.2.0 keeps the existing Promise surface while adding newer quality-of-life APIs.

Existing APIs include:

```text
Promise.new
Promise.defer
Promise.resolve
Promise.reject
Promise.try

Promise.pending
Promise.withResolvers

Promise.all
Promise.allPacked
Promise.allSettled
Promise.race
Promise.any
Promise.map
Promise.mapLimit
Promise.each
Promise.filter

Promise.retry
Promise.retryDelay
Promise.retryAsync
Promise.retryBackoff
Promise.retryUntilSuccess
Promise.repeatUntil

Promise.delay
Promise.delayValue
Promise.timeout

Promise.fromEvent
Promise.fromSignal
Promise.fromEvents

Promise.LogMessage
Promise.CreateEmbed
Promise.sendToDiscord

CancellationToken
uppercase method aliases
timeOut
```

Newer QOL APIs include:

```text
Promise.tryNow
Promise.async
Promise.first
Promise.settleAll

promise:isSettled()
promise:result()
promise:unwrap()
promise:Unwrap()
```

---

# Testing

Place `Promise.lua` in `ReplicatedStorage`.

Then run:

```text
tests/PromiseTests.server.lua
```

from:

```text
ServerScriptService
```

For performance testing, run:

```text
benchmarks/Benchmark.server.lua
```

from the same environment.

When comparing Promise versions, use the same:

* Roblox Studio version
* machine
* execution environment
* benchmark rounds
* warmup count
* native/optimization settings

This provides a much more reliable before/after comparison.

---

# Example Project Structure

```text
ReplicatedStorage
├── Promise.lua
└── Packages
    └── ...

ServerScriptService
├── Main.server.lua
├── tests
│   └── PromiseTests.server.lua
└── benchmarks
    └── Benchmark.server.lua
```

---

# Version

```lua
print(Promise.VERSION)
-- 1.2.0
```

**Current version: `1.2.0`**
