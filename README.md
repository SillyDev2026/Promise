# Lua Promise Module

A fully-featured, type-safe, and chainable **Promise implementation for Roblox/Lua**, designed to make asynchronous programming clean, readable, and maintainable.

---

## Features

* **Chainable `.andThen()` and `.catch()`** for sequential asynchronous operations
* **`.finally()`** for cleanup operations regardless of fulfillment or rejection
* **`.Error()`** for structured error handling
* **`Promise.all()`**, `Promise.race()`, and `Promise.filter()`** for aggregating multiple Promises
* **Retry utilities**: `retry`, `retryDelay`, `retryAsync`
* **Delay & timeout utilities**: `Promise.delay`, `Promise.timeOut`
* **Thread & coroutine support**: `Promise.resume`, `Promise.wrap`
* **Event-based promises**: `Promise.fromEvent`, `Promise.fromEvents`
* **Discord integration**: `Promise.sendToDiscord`
* **Embed creation**: `Promise.CreateEmbed`
* Fully **stackable** and **type-safe** with Luau generics

---

## Installation

Place the `Promise` module in `ReplicatedStorage` or any other shared directory:

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Promise = require(ReplicatedStorage.Promise)
```

---

## Basic Usage

### Creating a Promise

```lua
local promise = Promise.new(function(resolve, reject)
    task.delay(1, function()
        resolve("Hello World")
    end)
end)

promise:andThen(function(result)
    print(result)  -- Output: Hello World
end)
```

### Chaining Promises

```lua
Promise.resolve(5)
    :andThen(function(val) return val * 2 end)
    :andThen(function(val) print(val) end)
```

### Error Handling

```lua
Promise.new(function(resolve, reject)
    reject("Something went wrong")
end)
:catch(function(err)
    print("Error:", err)
end)
```

### Finally

```lua
Promise.resolve(10)
    :finally(function()
        print("Done")
    end)
```

---

## Advanced Utilities

```lua
-- Retry with delay
Promise.retryDelay(function(resolve, reject)
    -- async operation
end, 3, 0.5)

-- Aggregate multiple Promises
Promise.all({
    Promise.resolve(1),
    Promise.resolve(2),
    Promise.resolve(3)
}):andThen(function(results)
    print(results) -- {1, 2, 3}
end)

-- Wait for first to finish
Promise.race({
    Promise.delay(1):andThen(function() return "First" end),
    Promise.delay(2):andThen(function() return "Second" end)
}):andThen(print) -- "First"
```

---

## Event-based Promises

```lua
local eventPromise = Promise.fromEvent(someEvent)
eventPromise:andThen(function(...)
    print("Event fired with:", ...)
end)
```

---

## Discord Integration

```lua
Promise.sendToDiscord("WEBHOOK_URL", {
    content = "Hello from Roblox!"
}):andThen(function(res)
    print("Message sent successfully")
end):catch(function(err)
    warn(err)
end)
```

---

## Contributing

1. Fork the repository
2. Make your improvements
3. Submit a pull request with a detailed description of changes

---

## License

MIT License – Free to use, modify, and distribute.
