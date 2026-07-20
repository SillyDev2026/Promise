# Promise

A lightweight, optimized Promise implementation for Roblox Luau.

Built with Luau optimizations (`--!native` and `--!optimize 2`), this library provides a familiar asynchronous programming API inspired by JavaScript Promises while taking advantage of Roblox's task scheduler.

---

## Features

- ⚡ Fast and lightweight
- 🔄 Promise chaining
- ❌ Error handling
- 🏁 `finally()` support
- ⏳ Delays and timeouts
- 🔁 Automatic retries
- 🏎️ Promise racing
- 📦 Promise collections
- 📡 Event-to-Promise conversion
- 🚫 Cancellation tokens
- 📝 Logging helpers
- 💬 Discord webhook support
- 📄 Discord embed validation
- 🧠 Microtask callback queue

---

# Installation

Clone or copy the module into your project.

```lua
local Promise = require(path.To.Promise)
```

---

# Creating a Promise

```lua
local Promise = require(path.To.Promise)

Promise.new(function(resolve, reject)
    task.wait(1)
    resolve("Hello World!")
end)
:andThen(function(result)
    print(result)
end)
```

---

# Chaining

```lua
Promise.resolve(5)
:andThen(function(value)
    return value * 2
end)
:andThen(function(value)
    print(value)
end)
```

---

# Error Handling

```lua
Promise.new(function(resolve, reject)
    reject("Something went wrong")
end)
:catch(function(err)
    warn(err)
end)
```

---

# Finally

```lua
Promise.delay(2)
:finally(function()
    print("Finished!")
end)
```

---

# Delay

```lua
Promise.delay(3)
:andThen(function()
    print("3 seconds later")
end)
```

---

# Promise.resolve()

```lua
Promise.resolve("Success")
:andThen(print)
```

---

# Promise.reject()

```lua
Promise.reject("Failed")
:catch(print)
```

---

# Promise.all()

Waits for every Promise to finish.

```lua
Promise.all({
    Promise.delay(1),
    Promise.delay(2),
    Promise.delay(3)
})
:andThen(function(results)
    print("All complete")
end)
```

---

# Promise.race()

Returns the first Promise to finish.

```lua
Promise.race({
    Promise.delay(5),
    Promise.delay(1)
})
```

---

# Timeout

```lua
Promise.timeOut(
    Promise.delay(10),
    3
)
:catch(function(err)
    warn(err)
end)
```

---

# Retry

Retry until successful.

```lua
Promise.retry(function(resolve, reject)
    if math.random() > .5 then
        resolve("Success")
    else
        reject("Retry")
    end
end, 5)
```

---

# Retry With Delay

```lua
Promise.retryDelay(function(resolve, reject)
    reject("Failed")
end, 10, 1)
```

---

# Retry Async

Uses sensible defaults.

```lua
Promise.retryAsync(function(resolve, reject)
    resolve("Done")
end)
```

Default values:

- Retries: **30**
- Delay: **0.3 seconds**

---

# Await

```lua
local result = promise:await()
```

---

# Events

Convert a Roblox event into a Promise.

```lua
Promise.fromEvent(button.MouseButton1Click)
:andThen(function()
    print("Clicked!")
end)
```

---

# Multiple Events

```lua
Promise.fromEvents({
    signal1,
    signal2,
    signal3
})
```

Resolves once every event has fired.

---

# Cancellation Tokens

```lua
local token = Promise.CancellationToken.new()

local promise = Promise.new(function(resolve)
    task.wait(5)
    resolve("Finished")
end, token)

token:Cancel()
```

---

# Logging

```lua
Promise.LogMessage("Info", "Started")
Promise.LogMessage("Warn", "Low memory")
Promise.LogMessage("Debug", "Value = 42")
```

Error logging automatically rejects the Promise.

```lua
Promise.LogMessage("Error", "Something failed")
```

---

# Discord Embed Validation

```lua
Promise.CreateEmbed({
    title = "Example",
    description = "Hello!"
})
```

Checks:

- Embed is a table
- Title length
- Description length

---

# Discord Webhooks

```lua
Promise.sendToDiscord(
    WEBHOOK_URL,
    {
        content = "Hello!"
    }
)
```

Supports JSON payloads through `HttpService:PostAsync()`.

---

# API

## Constructors

| Function | Description |
|----------|-------------|
| `Promise.new()` | Creates a Promise |
| `Promise.resolve()` | Creates a resolved Promise |
| `Promise.reject()` | Creates a rejected Promise |

---

## Instance Methods

| Method | Description |
|---------|-------------|
| `:andThen()` | Chains Promises |
| `:catch()` | Handles errors |
| `:finally()` | Runs regardless of outcome |
| `:Error()` | Custom error callback |
| `:await()` | Waits synchronously |

---

## Utility Methods

| Function | Description |
|---------|-------------|
| `Promise.delay()` | Waits before resolving |
| `Promise.all()` | Waits for all Promises |
| `Promise.race()` | Returns first completed Promise |
| `Promise.timeOut()` | Rejects after timeout |
| `Promise.retry()` | Retries executor |
| `Promise.retryDelay()` | Retries with delay |
| `Promise.retryAsync()` | Async retry helper |
| `Promise.fromEvent()` | Converts one event |
| `Promise.fromEvents()` | Converts multiple events |
| `Promise.LogMessage()` | Promise-based logger |
| `Promise.CreateEmbed()` | Discord embed validator |
| `Promise.sendToDiscord()` | Sends webhook requests |

---

# Performance

This library is designed for Roblox Luau and makes use of:

- `--!native`
- `--!optimize 2`
- `task.spawn`
- `task.defer`
- Custom microtask scheduling
- Minimal allocations

---

# Requirements

- Roblox Studio
- Luau
- `HttpService` enabled for webhook support

---

# License

MIT License

Feel free to modify, improve, and use this project in your own Roblox experiences.
