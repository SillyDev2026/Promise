--!native
--!optimize 2

local HttpService = game:GetService("HttpService")

export type Status = "PENDING" | "FULFILLED" | "REJECTED" | "CANCELLED"
export type Resolve = (...any) -> ()
export type Reject = (...any) -> ()
export type CancelHandler = (reason: any) -> ()
export type Disconnectable = {
	Disconnect: (self: Disconnectable) -> (),
}
export type OnCancel = (handler: CancelHandler) -> Disconnectable
export type Executor = (resolve: Resolve, reject: Reject, onCancel: OnCancel) -> ()
export type Handler = (...any) -> ...any
export type Predicate = (...any) -> boolean
export type CancellationToken = {
	IsCancelled: (self: CancellationToken) -> boolean,
	GetReason: (self: CancellationToken) -> any,
	OnCancel: (self: CancellationToken, callback: CancelHandler) -> Disconnectable,
	Cancel: (self: CancellationToken, reason: any?) -> boolean,
	ThrowIfCancelled: (self: CancellationToken) -> (),
	Destroy: (self: CancellationToken) -> (),
	isCancelled: (self: CancellationToken) -> boolean,
	getReason: (self: CancellationToken) -> any,
	onCancel: (self: CancellationToken, callback: CancelHandler) -> Disconnectable,
	cancel: (self: CancellationToken, reason: any?) -> boolean,
}
export type CancellationTokenClass = {
	new: () -> CancellationToken,
}
export type Promise = {
	andThen: (self: Promise, onFulfilled: Handler?, onRejected: Handler?) -> Promise,
	Then: (self: Promise, onFulfilled: Handler?, onRejected: Handler?) -> Promise,
	catch: (self: Promise, onRejected: Handler) -> Promise,
	Catch: (self: Promise, onRejected: Handler) -> Promise,
	Error: (self: Promise, onRejected: Handler) -> Promise,
	finally: (self: Promise, onFinally: Handler) -> Promise,
	Finally: (self: Promise, onFinally: Handler) -> Promise,
	tap: (self: Promise, callback: Handler) -> Promise,
	tapCatch: (self: Promise, callback: Handler) -> Promise,
	andThenCall: (self: Promise, callback: Handler, ...any) -> Promise,
	andThenReturn: (self: Promise, ...any) -> Promise,
	catchCall: (self: Promise, callback: Handler, ...any) -> Promise,
	catchReturn: (self: Promise, ...any) -> Promise,
	cancel: (self: Promise, reason: any?) -> boolean,
	Cancel: (self: Promise, reason: any?) -> boolean,
	onCancel: (self: Promise, callback: CancelHandler) -> Disconnectable,
	getStatus: (self: Promise) -> Status,
	status: (self: Promise) -> Status,
	isPending: (self: Promise) -> boolean,
	isFulfilled: (self: Promise) -> boolean,
	isRejected: (self: Promise) -> boolean,
	isCancelled: (self: Promise) -> boolean,
	isSettled: (self: Promise) -> boolean,
	result: (self: Promise) -> (Status, ...any),
	awaitStatus: (self: Promise) -> (Status, ...any),
	AwaitStatus: (self: Promise) -> (Status, ...any),
	await: (self: Promise) -> (boolean, ...any),
	Await: (self: Promise) -> (boolean, ...any),
	expect: (self: Promise) -> ...any,
	Expect: (self: Promise) -> ...any,
	unwrap: (self: Promise) -> ...any,
	Unwrap: (self: Promise) -> ...any,
	now: (self: Promise) -> Promise,
	withTimeout: (self: Promise, seconds: number, reason: any?, cancelSource: boolean?) -> Promise,
	timeout: (self: Promise, seconds: number, reason: any?, cancelSource: boolean?) -> Promise,
	timeOut: (self: Promise, seconds: number, reason: any?, cancelSource: boolean?) -> Promise,
}
export type Deferred = {
	promise: Promise,
	resolve: Resolve,
	reject: Reject,
	cancel: (reason: any?) -> (),
}
export type SettledResult = {
	status: Status,
	value: any?,
	reason: any?,
	values: { any },
}
export type DiscordEmbedField = {
	name: string,
	value: string,
	inline: boolean?,
}
export type DiscordEmbed = {
	title: string?,
	description: string?,
	url: string?,
	color: number?,
	fields: { DiscordEmbedField }?,
	footer: any?,
	author: any?,
	thumbnail: any?,
	image: any?,
	timestamp: string?,
}
export type PromiseModule = {
	VERSION: string,
	Status: {
		Pending: Status,
		Fulfilled: Status,
		Rejected: Status,
		Cancelled: Status,
	},
	CancellationToken: CancellationTokenClass,
	newCancellationToken: () -> CancellationToken,
	new: (executor: Executor, token: CancellationToken?) -> Promise,
	defer: (executor: Executor, token: CancellationToken?) -> Promise,
	pending: () -> Deferred,
	withResolvers: () -> Deferred,
	resolve: (...any) -> Promise,
	reject: (...any) -> Promise,
	try: (callback: Handler, ...any) -> Promise,
	tryNow: (callback: Handler, ...any) -> Promise,
	is: (value: any) -> boolean,
	isPromise: (value: any) -> boolean,
	all: (values: { any }) -> Promise,
	allPacked: (values: { any }) -> Promise,
	allSettled: (values: { any }) -> Promise,
	settleAll: (values: { any }) -> Promise,
	race: (values: { any }) -> Promise,
	first: (values: { any }) -> Promise,
	any: (values: { any }) -> Promise,
	map: (values: { any }, mapper: (value: any, index: number) -> any) -> Promise,
	mapLimit: (values: { any }, concurrency: number, mapper: (value: any, index: number) -> any) -> Promise,
	each: (values: { any }, callback: (value: any, index: number) -> any) -> Promise,
	filter: (values: { any }, predicate: (value: any, index: number) -> any) -> Promise,
	retry: (executor: Executor, retries: number) -> Promise,
	retryDelay: (executor: Executor, retries: number, delaySeconds: number) -> Promise,
	retryAsync: (executor: Executor, retries: number?, delaySeconds: number?) -> Promise,
	retryBackoff: (executor: Executor, retries: number?, baseDelay: number?, maxDelay: number?) -> Promise,
	delay: (seconds: number) -> Promise,
	after: (seconds: number) -> Promise,
	delayValue: (seconds: number, ...any) -> Promise,
	never: () -> Promise,
	timeout: (value: any, seconds: number, reason: any?, cancelSource: boolean?) -> Promise,
	timeOut: (value: any, seconds: number, reason: any?, cancelSource: boolean?) -> Promise,
	resume: (thread: thread) -> Promise,
	wrap: (func: Handler) -> (...any) -> Promise,
	promisify: (func: Handler) -> (...any) -> Promise,
	async: (func: Handler) -> (...any) -> Promise,
	repeatUntil: (executor: Handler, delaySeconds: number?) -> Promise,
	retryUntilSuccess: (executor: Handler, delaySeconds: number?) -> Promise,
	fromEvent: (signal: RBXScriptSignal, predicate: Predicate?) -> Promise,
	fromSignal: (signal: RBXScriptSignal, predicate: Predicate?) -> Promise,
	fromEvents: (signals: { RBXScriptSignal }) -> Promise,
	LogMessage: (level: string, message: any) -> Promise,
	CreateEmbed: (embed: DiscordEmbed) -> Promise,
	sendToDiscord: (url: string, data: any, contentType: any?) -> Promise,
	Version: () -> string,
	print: () -> (),
}

local Promise: any = {}
Promise.__index = Promise

local VERSION = "1.2.0"
local PENDING: Status = "PENDING"
local FULFILLED: Status = "FULFILLED"
local REJECTED: Status = "REJECTED"
local CANCELLED: Status = "CANCELLED"

Promise.VERSION = VERSION
Promise.Status = table.freeze({
	Pending = PENDING,
	Fulfilled = FULFILLED,
	Rejected = REJECTED,
	Cancelled = CANCELLED,
})

type PackedValues = {
	n: number,
	[number]: any,
}

type CallbackRecord = {
	active: boolean,
	observer: boolean,
	fulfilled: Handler?,
	rejected: Handler?,
	cancelled: Handler?,
	resolve: Resolve?,
	reject: Reject?,
	cancel: ((reason: any?) -> ())?,
}

type PromiseInternal = Promise & {
	_state: Status,
	_value: any,
	_values: PackedValues?,
	_callbacks: { CallbackRecord },
	_cancelHandlers: { [number]: CancelHandler },
	_nextCancelHandlerId: number,
	_executorThread: thread?,
	_tokenConnection: Disconnectable?,
	_adoptDisconnect: (() -> ())?,
	_flushCallbacks: (self: PromiseInternal) -> (),
	_settle: (self: PromiseInternal, state: Status, values: PackedValues) -> boolean,
	_observe: (self: PromiseInternal, onFulfilled: any?, onRejected: any?, onCancelled: any?) -> (() -> ()),
	_runCallback: (self: PromiseInternal, callback: CallbackRecord) -> (),
	_chain: (self: PromiseInternal, onFulfilled: any?, onRejected: any?, onCancelled: any?) -> Promise,
}

type TokenInternal = CancellationToken & {
	_cancelled: boolean,
	_reason: any,
	_listeners: { [number]: CancelHandler },
	_nextListenerId: number,
}

local MICROTASK_BUDGET = 4096
local microtasks: { [number]: (() -> ())? } = {}
local microtaskHead = 1
local microtaskTail = 0
local microtaskScheduled = false

local EMPTY_VALUES: PackedValues = table.freeze({ n = 0 }) :: any

local function packed(...: any): PackedValues
	return table.pack(...) :: any
end

local function unpacked(values: PackedValues): ...any
	return table.unpack(values, 1, values.n)
end

local function runMicrotasks(): ()
	local processed = 0

	while microtaskHead <= microtaskTail and processed < MICROTASK_BUDGET do
		local index = microtaskHead
		microtaskHead += 1
		processed += 1

		local callback = microtasks[index]
		microtasks[index] = nil
		if callback then
			local ok, err = pcall(callback)
			if not ok then
				task.spawn(function()
					error(err, 0)
				end)
			end
		end
	end

	if microtaskHead > microtaskTail then
		microtasks = {}
		microtaskHead = 1
		microtaskTail = 0
		microtaskScheduled = false
	else
		task.defer(runMicrotasks)
	end
end

local function queueMicrotask(callback: () -> ()): ()
	microtaskTail += 1
	microtasks[microtaskTail] = callback
	if not microtaskScheduled then
		microtaskScheduled = true
		task.defer(runMicrotasks)
	end
end

local DISCONNECTED: Disconnectable = table.freeze({
	Disconnect = function(_self: any) end,
}) :: any

local function disconnected(): Disconnectable
	return DISCONNECTED
end

local CancellationToken: any = {}
CancellationToken.__index = CancellationToken

function CancellationToken.new(): CancellationToken
	return setmetatable({
		_cancelled = false,
		_reason = nil,
		_listeners = {},
		_nextListenerId = 0,
	}, CancellationToken) :: any
end

function CancellationToken:IsCancelled(): boolean
	return (self :: TokenInternal)._cancelled
end

function CancellationToken:GetReason(): any
	return (self :: TokenInternal)._reason
end

function CancellationToken:OnCancel(callback: CancelHandler): Disconnectable
	assert(type(callback) == "function", "Cancellation callback must be a function")
	local token = self :: TokenInternal

	if token._cancelled then
		local active = true
		queueMicrotask(function()
			if active then
				callback(token._reason)
			end
		end)
		return {
			Disconnect = function(_self: any)
				active = false
			end,
		}
	end

	token._nextListenerId += 1
	local listenerId = token._nextListenerId
	token._listeners[listenerId] = callback
	local connected = true

	return {
		Disconnect = function(_self: any)
			if connected then
				connected = false
				token._listeners[listenerId] = nil
			end
		end,
	}
end

function CancellationToken:Cancel(reason: any?): boolean
	local token = self :: TokenInternal
	if token._cancelled then
		return false
	end

	token._cancelled = true
	token._reason = if reason == nil then "Promise cancelled" else reason

	local listeners = token._listeners
	token._listeners = {}

	for _, callback in listeners do
		local captured = callback
		queueMicrotask(function()
			captured(token._reason)
		end)
	end

	return true
end

function CancellationToken:ThrowIfCancelled(): ()
	local token = self :: TokenInternal
	if token._cancelled then
		error(token._reason or "Promise cancelled", 2)
	end
end

function CancellationToken:Destroy(): ()
	self:Cancel("CancellationToken destroyed")
end

CancellationToken.isCancelled = CancellationToken.IsCancelled
CancellationToken.getReason = CancellationToken.GetReason
CancellationToken.onCancel = CancellationToken.OnCancel
CancellationToken.cancel = CancellationToken.Cancel

Promise.CancellationToken = CancellationToken
Promise.newCancellationToken = CancellationToken.new

local function newPending(): PromiseInternal
	return setmetatable({
		_state = PENDING,
		_value = nil,
		_values = nil,
		_callbacks = {},
		_cancelHandlers = {},
		_nextCancelHandlerId = 0,
		_executorThread = nil,
		_tokenConnection = nil,
		_adoptDisconnect = nil,
	}, Promise) :: any
end

local function newSettled(state: Status, values: PackedValues): PromiseInternal
	local promise = newPending()
	promise._state = state
	promise._values = values
	promise._value = values[1]
	return promise
end

function Promise.is(value: any): boolean
	return type(value) == "table" and getmetatable(value) == Promise
end

Promise.isPromise = Promise.is

local function removeCallback(owner: PromiseInternal, callback: CallbackRecord): ()
	if not callback.active then
		return
	end

	callback.active = false
	for i = #owner._callbacks, 1, -1 do
		if owner._callbacks[i] == callback then
			table.remove(owner._callbacks, i)
			break
		end
	end
end

function Promise:_flushCallbacks(): ()
	local selfPromise = self :: PromiseInternal
	if selfPromise._state == PENDING then
		return
	end

	local callbacks = selfPromise._callbacks
	if #callbacks == 0 then
		return
	end
	selfPromise._callbacks = {}

	queueMicrotask(function()
		for i = 1, #callbacks do
			local callback = callbacks[i]
			if callback.active then
				selfPromise:_runCallback(callback)
			end
		end
	end)
end

function Promise:_settle(state: Status, values: PackedValues): boolean
	local selfPromise = self :: PromiseInternal
	if selfPromise._state ~= PENDING then
		return false
	end

	selfPromise._state = state
	selfPromise._values = values
	selfPromise._value = values[1]

	if selfPromise._tokenConnection then
		selfPromise._tokenConnection:Disconnect()
		selfPromise._tokenConnection = nil
	end

	if selfPromise._adoptDisconnect then
		selfPromise._adoptDisconnect()
		selfPromise._adoptDisconnect = nil
	end

	if state ~= CANCELLED then
		selfPromise._cancelHandlers = {}
		selfPromise._executorThread = nil
	end

	selfPromise:_flushCallbacks()
	return true
end

local function cancelPending(selfPromise: PromiseInternal, reason: any?): boolean
	if selfPromise._state ~= PENDING then
		return false
	end

	local finalReason = if reason == nil then "Promise cancelled" else reason
	local handlers = selfPromise._cancelHandlers
	selfPromise._cancelHandlers = {}

	if not selfPromise:_settle(CANCELLED, packed(finalReason)) then
		return false
	end

	for _, handler in handlers do
		local ok, err = pcall(handler, finalReason)
		if not ok then
			warn("[Promise] cancellation handler failed: " .. tostring(err))
		end
	end

	local executorThread = selfPromise._executorThread
	selfPromise._executorThread = nil
	if executorThread and executorThread ~= coroutine.running() then
		pcall(task.cancel, executorThread)
	end

	return true
end

local function rejectPending(selfPromise: PromiseInternal, values: PackedValues): boolean
	if selfPromise._state ~= PENDING then
		return false
	end
	return selfPromise:_settle(REJECTED, values)
end

local resolvePending: (PromiseInternal, PackedValues) -> boolean
resolvePending = function(selfPromise: PromiseInternal, values: PackedValues): boolean
	if selfPromise._state ~= PENDING then
		return false
	end

	if values.n == 1 and Promise.is(values[1]) then
		local source = values[1] :: PromiseInternal
		if source == selfPromise then
			return rejectPending(selfPromise, packed("A Promise cannot resolve with itself"))
		end

		if source._state ~= PENDING then
			local sourceValues = source._values or EMPTY_VALUES
			if source._state == FULFILLED then
				return selfPromise:_settle(FULFILLED, sourceValues)
			elseif source._state == REJECTED then
				return selfPromise:_settle(REJECTED, sourceValues)
			else
				return cancelPending(selfPromise, sourceValues[1])
			end
		end

		selfPromise._adoptDisconnect = source:_observe(
			function(...: any)
				resolvePending(selfPromise, packed(...))
			end,
			function(...: any)
				rejectPending(selfPromise, packed(...))
			end,
			function(reasonValue: any)
				cancelPending(selfPromise, reasonValue)
			end
		)
		return true
	end

	return selfPromise:_settle(FULFILLED, values)
end

local function makeResolvers(selfPromise: PromiseInternal): (Resolve, Reject, (reason: any?) -> ())
	local function resolve(...: any)
		resolvePending(selfPromise, packed(...))
	end

	local function reject(...: any)
		rejectPending(selfPromise, packed(...))
	end

	local function cancel(reason: any?)
		cancelPending(selfPromise, reason)
	end

	return resolve, reject, cancel
end

function Promise:_observe(onFulfilled: Handler?, onRejected: Handler?, onCancelled: Handler?): () -> ()
	local selfPromise = self :: PromiseInternal
	local callback: CallbackRecord = {
		active = true,
		observer = true,
		fulfilled = onFulfilled,
		rejected = onRejected,
		cancelled = onCancelled,
		resolve = nil,
		reject = nil,
		cancel = nil,
	}

	selfPromise._callbacks[#selfPromise._callbacks + 1] = callback
	if selfPromise._state ~= PENDING then
		selfPromise:_flushCallbacks()
	end

	return function()
		removeCallback(selfPromise, callback)
	end
end

function Promise:_runCallback(callback: CallbackRecord): ()
	local selfPromise = self :: PromiseInternal
	local state = selfPromise._state
	local handler: Handler? = nil

	if state == FULFILLED then
		handler = callback.fulfilled
	elseif state == REJECTED then
		handler = callback.rejected
	elseif state == CANCELLED then
		handler = callback.cancelled or callback.rejected
	end

	local values = selfPromise._values or EMPTY_VALUES

	if callback.observer then
		if handler then
			local ok, err = pcall(handler, unpacked(values))
			if not ok then
				warn("[Promise] observer failed: " .. tostring(err))
			end
		end
		return
	end

	local resolve = callback.resolve :: Resolve
	local reject = callback.reject :: Reject
	local cancel = callback.cancel :: (reason: any?) -> ()

	if not handler then
		if state == FULFILLED then
			resolve(unpacked(values))
		elseif state == CANCELLED then
			cancel(values[1])
		else
			reject(unpacked(values))
		end
		return
	end

	local results = packed(pcall(handler, unpacked(values)))
	if not results[1] then
		reject(results[2])
		return
	end

	resolve(table.unpack(results, 2, results.n))
end

local function addCancelHandler(selfPromise: PromiseInternal, handler: CancelHandler): Disconnectable
	assert(type(handler) == "function", "onCancel handler must be a function")

	if selfPromise._state == CANCELLED then
		local reason = selfPromise._values and selfPromise._values[1] or "Promise cancelled"
		local active = true
		queueMicrotask(function()
			if active then
				handler(reason)
			end
		end)
		return {
			Disconnect = function(_self: any)
				active = false
			end,
		}
	end

	if selfPromise._state ~= PENDING then
		return disconnected()
	end

	selfPromise._nextCancelHandlerId += 1
	local handlerId = selfPromise._nextCancelHandlerId
	selfPromise._cancelHandlers[handlerId] = handler
	local connected = true

	return {
		Disconnect = function(_self: any)
			if connected then
				connected = false
				selfPromise._cancelHandlers[handlerId] = nil
			end
		end,
	}
end

local function startExecutor(selfPromise: PromiseInternal, executor: Executor, token: CancellationToken?, deferred: boolean): ()
	assert(type(executor) == "function", "Executor must be a function")
	local resolve, reject, cancel = makeResolvers(selfPromise)

	local function onCancel(handler: CancelHandler): Disconnectable
		return addCancelHandler(selfPromise, handler)
	end

	if token then
		assert(getmetatable(token) == CancellationToken, "token must be a Promise.CancellationToken")
		if token:IsCancelled() then
			cancel(token:GetReason())
			return
		end
		selfPromise._tokenConnection = token:OnCancel(cancel)
	end

	local function runner(): ()
		if selfPromise._state ~= PENDING then
			return
		end

		local ok, err = xpcall(function()
			executor(resolve, reject, onCancel)
		end, debug.traceback)

		if not ok then
			reject(err)
		end

		if selfPromise._executorThread == coroutine.running() then
			selfPromise._executorThread = nil
		end
	end

	local executorThread: thread
	if deferred then
		executorThread = task.defer(runner)
	else
		executorThread = task.spawn(runner)
	end
	selfPromise._executorThread = executorThread
	if coroutine.status(executorThread) == "dead" then
		selfPromise._executorThread = nil
	end
end

function Promise.new(executor: Executor, token: CancellationToken?): Promise
	local selfPromise = newPending()
	startExecutor(selfPromise, executor, token, false)
	return selfPromise
end

function Promise.defer(executor: Executor, token: CancellationToken?): Promise
	local selfPromise = newPending()
	startExecutor(selfPromise, executor, token, true)
	return selfPromise
end

function Promise.pending(): Deferred
	local selfPromise = newPending()
	local resolve, reject, cancel = makeResolvers(selfPromise)
	return {
		promise = selfPromise,
		resolve = resolve,
		reject = reject,
		cancel = cancel,
	}
end

Promise.withResolvers = Promise.pending

function Promise:_chain(onFulfilled: Handler?, onRejected: Handler?, onCancelled: Handler?): Promise
	local selfPromise = self :: PromiseInternal
	local child = newPending()
	local resolve, reject, cancel = makeResolvers(child)

	local callback: CallbackRecord = {
		active = true,
		observer = false,
		fulfilled = onFulfilled,
		rejected = onRejected,
		cancelled = onCancelled,
		resolve = resolve,
		reject = reject,
		cancel = cancel,
	}

	selfPromise._callbacks[#selfPromise._callbacks + 1] = callback
	addCancelHandler(child, function()
		removeCallback(selfPromise, callback)
	end)

	if selfPromise._state ~= PENDING then
		selfPromise:_flushCallbacks()
	end

	return child
end

function Promise:andThen(onFulfilled: Handler?, onRejected: Handler?): Promise
	if onFulfilled ~= nil then
		assert(type(onFulfilled) == "function", "onFulfilled must be a function or nil")
	end
	if onRejected ~= nil then
		assert(type(onRejected) == "function", "onRejected must be a function or nil")
	end
	return self:_chain(onFulfilled, onRejected, onRejected)
end

Promise.Then = Promise.andThen

function Promise:catch(onRejected: Handler): Promise
	assert(type(onRejected) == "function", "onRejected must be a function")
	return self:andThen(nil, onRejected)
end

Promise.Catch = Promise.catch
Promise.Error = Promise.catch

local function callAsPromise(callback: Handler, args: PackedValues?): Promise
	local results = if args then packed(pcall(callback, unpacked(args))) else packed(pcall(callback))
	if not results[1] then
		return Promise.reject(results[2])
	end
	return Promise.resolve(table.unpack(results, 2, results.n))
end

function Promise:finally(onFinally: Handler): Promise
	assert(type(onFinally) == "function", "onFinally must be a function")
	local source = self :: PromiseInternal
	local child = newPending()
	local resolve, reject, cancel = makeResolvers(child)
	local unsubscribe: (() -> ())? = nil
	local cleanupPromise: Promise? = nil

	local function finishAfter(state: Status, values: PackedValues): ()
		cleanupPromise = callAsPromise(onFinally)
		;(cleanupPromise :: PromiseInternal):_observe(
			function()
				cleanupPromise = nil
				if state == FULFILLED then
					resolve(unpacked(values))
				elseif state == REJECTED then
					reject(unpacked(values))
				else
					cancel(values[1])
				end
			end,
			function(...: any)
				cleanupPromise = nil
				reject(...)
			end,
			function(reason: any)
				cleanupPromise = nil
				cancel(reason)
			end
		)
	end

	unsubscribe = source:_observe(
		function(...: any)
			finishAfter(FULFILLED, packed(...))
		end,
		function(...: any)
			finishAfter(REJECTED, packed(...))
		end,
		function(reason: any)
			finishAfter(CANCELLED, packed(reason))
		end
	)

	addCancelHandler(child, function(reason: any)
		if unsubscribe then
			unsubscribe()
			unsubscribe = nil
		end
		if cleanupPromise and cleanupPromise:isPending() then
			cleanupPromise:cancel(reason)
		end
		cleanupPromise = nil
	end)

	return child
end

Promise.Finally = Promise.finally

function Promise:tap(callback: Handler): Promise
	assert(type(callback) == "function", "callback must be a function")
	return self:andThen(function(...: any)
		local original = packed(...)
		return callAsPromise(callback, original):andThen(function()
			return unpacked(original)
		end)
	end)
end

function Promise:tapCatch(callback: Handler): Promise
	assert(type(callback) == "function", "callback must be a function")
	local source = self :: PromiseInternal
	local child = newPending()
	local resolve, reject, cancel = makeResolvers(child)
	local unsubscribe: (() -> ())? = nil
	local cleanupPromise: Promise? = nil
	local cleanupUnsubscribe: (() -> ())? = nil

	unsubscribe = source:_observe(
		resolve,
		function(...: any)
			local original = packed(...)
			cleanupPromise = callAsPromise(callback, original)
			cleanupUnsubscribe = (cleanupPromise :: PromiseInternal):_observe(
				function()
					cleanupPromise = nil
					cleanupUnsubscribe = nil
					reject(unpacked(original))
				end,
				function(...: any)
					cleanupPromise = nil
					cleanupUnsubscribe = nil
					reject(...)
				end,
				function(reason: any)
					cleanupPromise = nil
					cleanupUnsubscribe = nil
					cancel(reason)
				end
			)
		end,
		cancel
	)

	addCancelHandler(child, function(reason: any)
		if unsubscribe then
			unsubscribe()
			unsubscribe = nil
		end
		if cleanupUnsubscribe then
			cleanupUnsubscribe()
			cleanupUnsubscribe = nil
		end
		if cleanupPromise and cleanupPromise:isPending() then
			cleanupPromise:cancel(reason)
		end
		cleanupPromise = nil
	end)

	return child
end

function Promise:andThenCall(callback: Handler, ...: any): Promise
	assert(type(callback) == "function", "callback must be a function")
	local args = packed(...)
	return self:andThen(function()
		return callback(unpacked(args))
	end)
end

function Promise:andThenReturn(...: any): Promise
	local values = packed(...)
	return self:andThen(function()
		return unpacked(values)
	end)
end

function Promise:catchCall(callback: Handler, ...: any): Promise
	assert(type(callback) == "function", "callback must be a function")
	local args = packed(...)
	return self:catch(function()
		return callback(unpacked(args))
	end)
end

function Promise:catchReturn(...: any): Promise
	local values = packed(...)
	return self:catch(function()
		return unpacked(values)
	end)
end

function Promise:onCancel(callback: CancelHandler): Disconnectable
	return addCancelHandler(self :: PromiseInternal, callback)
end

function Promise:cancel(reason: any?): boolean
	return cancelPending(self :: PromiseInternal, reason)
end

Promise.Cancel = Promise.cancel

function Promise:getStatus(): Status
	return (self :: PromiseInternal)._state
end

Promise.status = Promise.getStatus

function Promise:isPending(): boolean
	return (self :: PromiseInternal)._state == PENDING
end

function Promise:isFulfilled(): boolean
	return (self :: PromiseInternal)._state == FULFILLED
end

function Promise:isRejected(): boolean
	return (self :: PromiseInternal)._state == REJECTED
end

function Promise:isCancelled(): boolean
	return (self :: PromiseInternal)._state == CANCELLED
end

function Promise:isSettled(): boolean
	return (self :: PromiseInternal)._state ~= PENDING
end

function Promise:result(): (Status, ...any)
	local selfPromise = self :: PromiseInternal
	return selfPromise._state, unpacked(selfPromise._values or EMPTY_VALUES)
end

function Promise:awaitStatus(): (Status, ...any)
	local selfPromise = self :: PromiseInternal
	if selfPromise._state == PENDING then
		local thread = coroutine.running()
		local resumed = false
		local unsubscribe: (() -> ())? = nil

		local function wake(): ()
			if resumed then
				return
			end
			resumed = true
			if unsubscribe then
				unsubscribe()
				unsubscribe = nil
			end
			task.spawn(thread)
		end

		unsubscribe = selfPromise:_observe(wake, wake, wake)
		coroutine.yield()
	end

	return selfPromise._state, unpacked(selfPromise._values or EMPTY_VALUES)
end

Promise.AwaitStatus = Promise.awaitStatus

function Promise:await(): (boolean, ...any)
	local result = packed(self:awaitStatus())
	local status = result[1]
	if status == FULFILLED then
		return true, table.unpack(result, 2, result.n)
	end
	return false, table.unpack(result, 2, result.n)
end

Promise.Await = Promise.await

function Promise:expect(): ...any
	local result = packed(self:await())
	if not result[1] then
		error(result[2] or "Promise rejected", 2)
	end
	return table.unpack(result, 2, result.n)
end

Promise.Expect = Promise.expect
Promise.unwrap = Promise.expect
Promise.Unwrap = Promise.expect

function Promise:now(): Promise
	local selfPromise = self :: PromiseInternal
	local values = selfPromise._values or EMPTY_VALUES
	if selfPromise._state == FULFILLED then
		return newSettled(FULFILLED, values)
	elseif selfPromise._state == REJECTED then
		return newSettled(REJECTED, values)
	elseif selfPromise._state == CANCELLED then
		return newSettled(CANCELLED, values)
	end
	return newSettled(REJECTED, packed("Promise is not resolved"))
end

function Promise.resolve(...: any): Promise
	local count = select("#", ...)
	if count == 0 then
		return newSettled(FULFILLED, EMPTY_VALUES)
	end

	if count == 1 then
		local value = ...
		if Promise.is(value) then
			return value
		end
		return newSettled(FULFILLED, packed(value))
	end

	return newSettled(FULFILLED, packed(...))
end

function Promise.reject(...: any): Promise
	if select("#", ...) == 0 then
		return newSettled(REJECTED, EMPTY_VALUES)
	end
	return newSettled(REJECTED, packed(...))
end

function Promise.try(callback: Handler, ...: any): Promise
	assert(type(callback) == "function", "callback must be a function")
	local args = packed(...)
	return Promise.new(function(resolve: Resolve, reject: Reject)
		local results = packed(pcall(callback, unpacked(args)))
		if results[1] then
			resolve(table.unpack(results, 2, results.n))
		else
			reject(results[2])
		end
	end)
end

function Promise.tryNow(callback: Handler, ...: any): Promise
	assert(type(callback) == "function", "callback must be a function")
	local args = packed(...)
	local results = packed(pcall(callback, unpacked(args)))
	if results[1] then
		return Promise.resolve(table.unpack(results, 2, results.n))
	end
	return Promise.reject(results[2])
end

function Promise.all(values: { any }): Promise
	assert(type(values) == "table", "Promise.all expects a table")

	local total = #values
	local results = table.create(total)
	;(results :: any).n = total
	local promise = newPending()
	local resolve, reject, cancel = makeResolvers(promise)
	local completed = 0
	local children: { PromiseInternal } = table.create(total)
	local disconnects: { (() -> ())? } = table.create(total)
	local settled = false

	if total == 0 then
		resolve(results)
		return promise
	end

	local function cleanup(): ()
		for i = 1, total do
			local disconnect = disconnects[i]
			if disconnect then
				disconnects[i] = nil
				disconnect()
			end
		end
	end

	addCancelHandler(promise, function(reason: any)
		if settled then return end
		settled = true
		cleanup()
		for i = 1, total do
			local child = children[i]
			if child and child._state == PENDING then
				cancelPending(child, reason)
			end
		end
	end)

	for i = 1, total do
		local child = Promise.resolve(values[i]) :: PromiseInternal
		children[i] = child
		disconnects[i] = child:_observe(
			function(value: any)
				if settled then return end
				results[i] = value
				completed += 1
				if completed == total then
					settled = true
					cleanup()
					resolve(results)
				end
			end,
			function(...: any)
				if settled then return end
				settled = true
				local reasons = packed(...)
				cleanup()
				reject(unpacked(reasons))
			end,
			function(reason: any)
				if settled then return end
				settled = true
				cleanup()
				cancel(reason)
			end
		)
	end

	return promise
end
function Promise.allPacked(values: { any }): Promise
	assert(type(values) == "table", "Promise.allPacked expects a table")

	local total = #values
	local results = table.create(total)
	;(results :: any).n = total
	local promise = newPending()
	local resolve, reject, cancel = makeResolvers(promise)
	local completed = 0
	local children: { PromiseInternal } = table.create(total)
	local disconnects: { (() -> ())? } = table.create(total)
	local settled = false

	if total == 0 then
		resolve(results)
		return promise
	end

	local function cleanup(): ()
		for i = 1, total do
			local disconnect = disconnects[i]
			if disconnect then
				disconnects[i] = nil
				disconnect()
			end
		end
	end

	addCancelHandler(promise, function(reason: any)
		if settled then return end
		settled = true
		cleanup()
		for i = 1, total do
			local child = children[i]
			if child and child._state == PENDING then
				cancelPending(child, reason)
			end
		end
	end)

	for i = 1, total do
		local child = Promise.resolve(values[i]) :: PromiseInternal
		children[i] = child
		disconnects[i] = child:_observe(
			function(...: any)
				if settled then return end
				results[i] = packed(...)
				completed += 1
				if completed == total then
					settled = true
					cleanup()
					resolve(results)
				end
			end,
			function(...: any)
				if settled then return end
				settled = true
				local reasons = packed(...)
				cleanup()
				reject(unpacked(reasons))
			end,
			function(reason: any)
				if settled then return end
				settled = true
				cleanup()
				cancel(reason)
			end
		)
	end

	return promise
end
function Promise.allSettled(values: { any }): Promise
	assert(type(values) == "table", "Promise.allSettled expects a table")

	local total = #values
	local results = table.create(total)
	local promise = newPending()
	local resolve, _, _ = makeResolvers(promise)
	local completed = 0
	local disconnects: { (() -> ())? } = table.create(total)
	local done = false

	if total == 0 then
		resolve(results)
		return promise
	end

	local function cleanup(): ()
		for i = 1, total do
			local disconnect = disconnects[i]
			if disconnect then
				disconnects[i] = nil
				disconnect()
			end
		end
	end

	addCancelHandler(promise, function(_reason: any)
		done = true
		cleanup()
	end)

	local function finish(index: number, status: Status, valuesPack: PackedValues): ()
		if done then return end
		if status == FULFILLED then
			results[index] = { status = FULFILLED, value = valuesPack[1], values = valuesPack }
		elseif status == REJECTED then
			results[index] = { status = REJECTED, reason = valuesPack[1], values = valuesPack }
		else
			results[index] = { status = CANCELLED, reason = valuesPack[1], values = valuesPack }
		end

		completed += 1
		if completed == total then
			done = true
			cleanup()
			resolve(results)
		end
	end

	for i = 1, total do
		local source = Promise.resolve(values[i]) :: PromiseInternal
		disconnects[i] = source:_observe(
			function(...: any) finish(i, FULFILLED, packed(...)) end,
			function(...: any) finish(i, REJECTED, packed(...)) end,
			function(...: any) finish(i, CANCELLED, packed(...)) end
		)
	end

	return promise
end
function Promise.race(values: { any }): Promise
	assert(type(values) == "table", "Promise.race expects a table")

	local total = #values
	local promise = newPending()
	local resolve, reject, cancel = makeResolvers(promise)
	local children: { PromiseInternal } = table.create(total)
	local disconnects: { (() -> ())? } = table.create(total)
	local settled = false

	local function cleanup(): ()
		for i = 1, total do
			local disconnect = disconnects[i]
			if disconnect then
				disconnects[i] = nil
				disconnect()
			end
		end
	end

	addCancelHandler(promise, function(reason: any)
		if settled then return end
		settled = true
		cleanup()
		for i = 1, total do
			local child = children[i]
			if child and child._state == PENDING then
				cancelPending(child, reason)
			end
		end
	end)

	for i = 1, total do
		local child = Promise.resolve(values[i]) :: PromiseInternal
		children[i] = child
		disconnects[i] = child:_observe(
			function(...: any)
				if settled then return end
				settled = true
				local result = packed(...)
				cleanup()
				resolve(unpacked(result))
			end,
			function(...: any)
				if settled then return end
				settled = true
				local result = packed(...)
				cleanup()
				reject(unpacked(result))
			end,
			function(reason: any)
				if settled then return end
				settled = true
				cleanup()
				cancel(reason)
			end
		)
	end

	return promise
end
function Promise.any(values: { any }): Promise
	assert(type(values) == "table", "Promise.any expects a table")

	local total = #values
	if total == 0 then
		return Promise.reject("Promise.any received an empty table")
	end

	local promise = newPending()
	local resolve, reject, _ = makeResolvers(promise)
	local failed = 0
	local reasons = table.create(total)
	local disconnects: { (() -> ())? } = table.create(total)
	local settled = false

	local function cleanup(): ()
		for i = 1, total do
			local disconnect = disconnects[i]
			if disconnect then
				disconnects[i] = nil
				disconnect()
			end
		end
	end

	addCancelHandler(promise, function(_reason: any)
		settled = true
		cleanup()
	end)

	local function win(...: any): ()
		if settled then return end
		settled = true
		local result = packed(...)
		cleanup()
		resolve(unpacked(result))
	end

	local function recordFailure(index: number, reason: any): ()
		if settled then return end
		reasons[index] = reason
		failed += 1
		if failed == total then
			settled = true
			cleanup()
			reject(reasons)
		end
	end

	for i = 1, total do
		local source = Promise.resolve(values[i]) :: PromiseInternal
		disconnects[i] = source:_observe(
			win,
			function(reason: any) recordFailure(i, reason) end,
			function(reason: any) recordFailure(i, reason) end
		)
	end

	return promise
end
function Promise.map(values: { any }, mapper: (value: any, index: number) -> any): Promise
	assert(type(values) == "table", "Promise.map expects a table")
	assert(type(mapper) == "function", "Promise.map expects a mapper function")

	local mapped = table.create(#values)
	for i = 1, #values do
		mapped[i] = Promise.resolve(values[i]):andThen(function(value: any)
			return mapper(value, i)
		end)
	end
	return Promise.all(mapped)
end

function Promise.mapLimit(values: { any }, concurrency: number, mapper: (value: any, index: number) -> any): Promise
	assert(type(values) == "table", "Promise.mapLimit expects a table")
	assert(type(concurrency) == "number" and concurrency >= 1 and concurrency % 1 == 0, "concurrency must be a positive integer")
	assert(type(mapper) == "function", "Promise.mapLimit expects a mapper function")

	local total = #values
	local results = table.create(total)
	;(results :: any).n = total
	local promise = newPending()
	local resolve, reject, cancel = makeResolvers(promise)
	local nextIndex = 1
	local completed = 0
	local activeCount = 0
	local active: { [number]: PromiseInternal } = {}
	local disconnects: { [number]: () -> () } = {}
	local stopped = false

	if total == 0 then
		resolve(results)
		return promise
	end

	local function stopActive(reason: any?): ()
		for index, disconnect in disconnects do
			disconnects[index] = nil
			disconnect()
		end
		for index, child in active do
			active[index] = nil
			if child._state == PENDING then
				cancelPending(child, reason)
			end
		end
		activeCount = 0
	end

	addCancelHandler(promise, function(reason: any)
		if stopped then return end
		stopped = true
		stopActive(reason)
	end)

	local launch: () -> ()
	launch = function()
		if stopped then return end

		while nextIndex <= total and activeCount < concurrency do
			local index = nextIndex
			nextIndex += 1
			activeCount += 1

			local child = Promise.resolve(values[index]):andThen(function(value: any)
				return mapper(value, index)
			end) :: PromiseInternal
			active[index] = child

			disconnects[index] = child:_observe(
				function(value: any)
					if stopped then return end
					disconnects[index] = nil
					active[index] = nil
					activeCount -= 1
					results[index] = value
					completed += 1
					if completed == total then
						stopped = true
						resolve(results)
					else
						launch()
					end
				end,
				function(...: any)
					if stopped then return end
					local reasons = packed(...)
					disconnects[index] = nil
					active[index] = nil
					activeCount -= 1
					stopped = true
					stopActive(reasons[1])
					reject(unpacked(reasons))
				end,
				function(reason: any)
					if stopped then return end
					disconnects[index] = nil
					active[index] = nil
					activeCount -= 1
					stopped = true
					stopActive(reason)
					cancel(reason)
				end
			)
		end
	end

	launch()
	return promise
end
function Promise.each(values: { any }, callback: (value: any, index: number) -> any): Promise
	assert(type(values) == "table", "Promise.each expects a table")
	assert(type(callback) == "function", "Promise.each expects a callback")

	local results = table.create(#values)
	;(results :: any).n = #values
	local chain = Promise.resolve()

	for i = 1, #values do
		chain = chain:andThen(function()
			return Promise.resolve(values[i]):andThen(function(value: any)
				return callback(value, i)
			end):andThen(function(result: any)
				results[i] = result
			end)
		end)
	end

	return chain:andThen(function()
		return results
	end)
end

function Promise.filter(values: { any }, filterFunc: (value: any, index: number) -> any): Promise
	assert(type(values) == "table", "Promise.filter expects a table")
	assert(type(filterFunc) == "function", "Promise.filter expects a filter function")

	return Promise.all(values):andThen(function(results: { any })
		local total = ((results :: any).n :: number?) or #results
		local checks = table.create(total)
		for i = 1, total do
			checks[i] = Promise.try(filterFunc, results[i], i)
		end
		return Promise.all(checks):andThen(function(flags: { any })
			local filtered = {}
			local count = 0
			for i = 1, total do
				if flags[i] then
					count += 1
					filtered[count] = results[i]
				end
			end
			;(filtered :: any).n = count
			return filtered
		end)
	end)
end

local function validateRetries(retries: number): ()
	assert(type(retries) == "number" and retries >= 0 and retries % 1 == 0, "retries must be a non-negative integer")
end

local function retryInternal(executor: Executor, retries: number, delaySeconds: number?): Promise
	assert(type(executor) == "function", "Executor must be a function")
	validateRetries(retries)

	return Promise.new(function(resolve: Resolve, reject: Reject, onCancel: OnCancel)
		local cancelled = false
		local current: Promise? = nil
		local attempt = 0

		onCancel(function(reason: any)
			cancelled = true
			if current and current:isPending() then
				current:cancel(reason)
			end
		end)

		local runAttempt: () -> ()
		runAttempt = function()
			if cancelled then
				return
			end

			current = Promise.new(executor)
			;(current :: Promise):andThen(resolve, function(...: any)
				local reasons = packed(...)
				if attempt >= retries then
					reject(unpacked(reasons))
					return
				end

				attempt += 1
				if delaySeconds and delaySeconds > 0 then
					current = Promise.delay(delaySeconds)
					;(current :: Promise):andThen(runAttempt)
				else
					queueMicrotask(runAttempt)
				end
			end)
		end

		runAttempt()
	end)
end

function Promise.retry(executor: Executor, retries: number): Promise
	return retryInternal(executor, retries, nil)
end

function Promise.retryDelay(executor: Executor, retries: number, delaySeconds: number): Promise
	assert(type(delaySeconds) == "number" and delaySeconds >= 0, "delaySeconds must be >= 0")
	return retryInternal(executor, retries, delaySeconds)
end

function Promise.retryAsync(executor: Executor, retries: number?, delaySeconds: number?): Promise
	return retryInternal(executor, retries or 30, delaySeconds or 0.3)
end

function Promise.retryBackoff(executor: Executor, retries: number?, baseDelay: number?, maxDelay: number?): Promise
	assert(type(executor) == "function", "Executor must be a function")
	local retryCount = retries or 5
	local base = baseDelay or 0.25
	local maximum = maxDelay or 5
	validateRetries(retryCount)
	assert(type(base) == "number" and base >= 0, "baseDelay must be >= 0")
	assert(type(maximum) == "number" and maximum >= base, "maxDelay must be >= baseDelay")

	return Promise.new(function(resolve: Resolve, reject: Reject, onCancel: OnCancel)
		local cancelled = false
		local current: Promise? = nil
		local attempt = 0

		onCancel(function(reason: any)
			cancelled = true
			if current and current:isPending() then
				current:cancel(reason)
			end
		end)

		local run: () -> ()
		run = function()
			if cancelled then
				return
			end

			current = Promise.new(executor)
			;(current :: Promise):andThen(resolve, function(...: any)
				local reasons = packed(...)
				if attempt >= retryCount then
					reject(unpacked(reasons))
					return
				end

				local waitTime = math.min(base * (2 ^ attempt), maximum)
				attempt += 1
				current = Promise.delay(waitTime)
				;(current :: Promise):andThen(run)
			end)
		end

		run()
	end)
end

function Promise.delay(seconds: number): Promise
	assert(type(seconds) == "number" and seconds >= 0, "seconds must be >= 0")

	local promise = newPending()
	local resolve, _, _ = makeResolvers(promise)
	local started = os.clock()
	local timer = task.delay(seconds, function()
		resolve(os.clock() - started)
	end)

	addCancelHandler(promise, function(_reason: any)
		pcall(task.cancel, timer)
	end)

	return promise
end

Promise.after = Promise.delay

function Promise.delayValue(seconds: number, ...: any): Promise
	assert(type(seconds) == "number" and seconds >= 0, "seconds must be >= 0")
	local values = packed(...)
	local promise = newPending()
	local resolve, _, _ = makeResolvers(promise)
	local timer = task.delay(seconds, function()
		resolve(unpacked(values))
	end)

	addCancelHandler(promise, function(_reason: any)
		pcall(task.cancel, timer)
	end)

	return promise
end

function Promise.never(): Promise
	return newPending()
end

function Promise.timeout(value: any, seconds: number, reason: any?, cancelSource: boolean?): Promise
	assert(type(seconds) == "number" and seconds >= 0, "seconds must be >= 0")
	local source = Promise.resolve(value) :: PromiseInternal
	if source._state ~= PENDING then
		return source
	end

	local result = newPending()
	local resolve, reject, cancel = makeResolvers(result)
	local settled = false
	local unsubscribe: (() -> ())? = nil
	local timeoutReason = if reason == nil then "Promise timed out" else reason
	local timer: thread? = nil

	local function stopTimer(): ()
		local currentTimer = timer
		timer = nil
		if currentTimer then
			pcall(task.cancel, currentTimer)
		end
	end

	local function stopObserver(): ()
		local currentUnsubscribe = unsubscribe
		unsubscribe = nil
		if currentUnsubscribe then
			currentUnsubscribe()
		end
	end

	unsubscribe = source:_observe(
		function(...: any)
			if settled then return end
			settled = true
			stopTimer()
			stopObserver()
			resolve(...)
		end,
		function(...: any)
			if settled then return end
			settled = true
			stopTimer()
			stopObserver()
			reject(...)
		end,
		function(cancelReason: any)
			if settled then return end
			settled = true
			stopTimer()
			stopObserver()
			cancel(cancelReason)
		end
	)

	timer = task.delay(seconds, function()
		if settled then return end
		settled = true
		stopObserver()
		if cancelSource == true and source._state == PENDING then
			cancelPending(source, timeoutReason)
		end
		reject(timeoutReason)
	end)

	addCancelHandler(result, function(cancelReason: any)
		if settled then return end
		settled = true
		stopTimer()
		stopObserver()
		if cancelSource == true and source._state == PENDING then
			cancelPending(source, cancelReason)
		end
	end)

	return result
end

Promise.timeOut = Promise.timeout

function Promise:withTimeout(seconds: number, reason: any?, cancelSource: boolean?): Promise
	return Promise.timeout(self, seconds, reason, cancelSource)
end

function Promise.resume(threadValue: thread): Promise
	assert(type(threadValue) == "thread", "Promise.resume expects a thread")
	return Promise.new(function(resolve: Resolve, reject: Reject)
		local results = packed(coroutine.resume(threadValue))
		if results[1] then
			resolve(table.unpack(results, 2, results.n))
		else
			reject(results[2])
		end
	end)
end

function Promise.wrap(func: Handler): (...any) -> Promise
	assert(type(func) == "function", "Promise.wrap expects a function")
	return function(...: any): Promise
		return Promise.try(func, ...)
	end
end

Promise.promisify = Promise.wrap
Promise.async = Promise.wrap

function Promise.repeatUntil(executor: Handler, delaySeconds: number?): Promise
	assert(type(executor) == "function", "executor must be a function")
	local delayTime = delaySeconds or 0
	assert(type(delayTime) == "number" and delayTime >= 0, "delaySeconds must be >= 0")

	return Promise.new(function(resolve: Resolve, _reject: Reject, onCancel: OnCancel)
		local cancelled = false
		onCancel(function(_reason: any)
			cancelled = true
		end)

		while not cancelled do
			local results = packed(pcall(executor))
			if results[1] then
				resolve(table.unpack(results, 2, results.n))
				return
			end
			if delayTime > 0 then
				task.wait(delayTime)
			else
				task.wait()
			end
		end
	end)
end

Promise.retryUntilSuccess = Promise.repeatUntil

function Promise.fromEvent(signal: RBXScriptSignal, predicate: Predicate?): Promise
	assert(typeof(signal) == "RBXScriptSignal", "Promise.fromEvent expects an RBXScriptSignal")
	if predicate ~= nil then
		assert(type(predicate) == "function", "predicate must be a function or nil")
	end

	local promise = newPending()
	local resolve, reject, _ = makeResolvers(promise)
	local connection: RBXScriptConnection? = nil
	local settled = false

	connection = signal:Connect(function(...: any)
		if settled then
			return
		end

		if predicate then
			local check = packed(pcall(predicate, ...))
			if not check[1] then
				settled = true
				local current = connection
				connection = nil
				if current and current.Connected then
					current:Disconnect()
				end
				reject(check[2])
				return
			end
			if not check[2] then
				return
			end
		end

		settled = true
		local current = connection
		connection = nil
		if current and current.Connected then
			current:Disconnect()
		end
		resolve(...)
	end)

	addCancelHandler(promise, function(_reason: any)
		settled = true
		local current = connection
		connection = nil
		if current and current.Connected then
			current:Disconnect()
		end
	end)

	return promise
end

Promise.fromSignal = Promise.fromEvent

function Promise.fromEvents(signals: { RBXScriptSignal }): Promise
	assert(type(signals) == "table", "Promise.fromEvents expects a table")

	local total = #signals
	if total == 0 then
		local results = table.create(0)
		;(results :: any).n = 0
		return Promise.resolve(results)
	end

	for i = 1, total do
		assert(typeof(signals[i]) == "RBXScriptSignal", "Promise.fromEvents expects only RBXScriptSignals")
	end

	local promise = newPending()
	local resolve, _, _ = makeResolvers(promise)
	local completed = 0
	local results = table.create(total)
	;(results :: any).n = total
	local connections: { RBXScriptConnection? } = table.create(total)
	local fired: { boolean } = table.create(total, false)
	local done = false

	local function disconnectAll(): ()
		for i = 1, total do
			local connection = connections[i]
			connections[i] = nil
			if connection and connection.Connected then
				connection:Disconnect()
			end
		end
	end

	addCancelHandler(promise, function(_reason: any)
		done = true
		disconnectAll()
	end)

	for i = 1, total do
		local signal = signals[i]
		connections[i] = signal:Connect(function(...: any)
			if done or fired[i] then
				return
			end

			fired[i] = true
			local connection = connections[i]
			connections[i] = nil
			if connection and connection.Connected then
				connection:Disconnect()
			end

			results[i] = packed(...)
			completed += 1
			if completed == total then
				done = true
				disconnectAll()
				resolve(results)
			end
		end)
	end

	return promise
end

Promise.settleAll = Promise.allSettled
Promise.first = Promise.race

local LOG_LEVELS: { [string]: boolean } = table.freeze({
	Debug = true,
	Info = true,
	Warn = true,
	Error = true,
})

function Promise.LogMessage(level: string, message: any): Promise
	return Promise.new(function(resolve: Resolve, reject: Reject)
		if not LOG_LEVELS[level] then
			reject("Invalid log level")
			return
		end

		local msg = string.format("[Promise] [%s] %s", level, tostring(message))
		if level == "Error" then
			reject(msg)
		elseif level == "Warn" then
			warn(msg)
			resolve(msg)
		else
			print(msg)
			resolve(msg)
		end
	end)
end

function Promise.CreateEmbed(embed: DiscordEmbed): Promise
	return Promise.new(function(resolve: Resolve, reject: Reject)
		if type(embed) ~= "table" then
			reject("Embed must be a table")
			return
		end

		if embed.title and #tostring(embed.title) > 256 then
			reject("Embed title exceeds 256 characters")
			return
		end

		if embed.description and #tostring(embed.description) > 4096 then
			reject("Embed description exceeds 4096 characters")
			return
		end

		if embed.fields then
			if type(embed.fields) ~= "table" then
				reject("Embed fields must be a table")
				return
			end
			if #embed.fields > 25 then
				reject("Embed cannot contain more than 25 fields")
				return
			end
			for i = 1, #embed.fields do
				local field = embed.fields[i]
				if type(field) ~= "table" then
					reject("Embed field " .. i .. " must be a table")
					return
				end
				if field.name and #tostring(field.name) > 256 then
					reject("Embed field name exceeds 256 characters")
					return
				end
				if field.value and #tostring(field.value) > 1024 then
					reject("Embed field value exceeds 1024 characters")
					return
				end
			end
		end

		resolve(embed)
	end)
end

function Promise.sendToDiscord(url: string, data: any, contentType: any?): Promise
	assert(type(url) == "string", "url must be a string")

	return Promise.new(function(resolve: Resolve, reject: Reject)
		local ok, result = pcall(function()
			local json = HttpService:JSONEncode(data)
			return HttpService:PostAsync(url, json, contentType or Enum.HttpContentType.ApplicationJson)
		end)

		if ok then
			resolve(result)
		else
			reject(result)
		end
	end)
end

function Promise.Version(): string
	return VERSION
end

function Promise.print(): ()
	print("Promise v" .. VERSION)
end

Promise.__tostring = function(self: PromiseInternal): string
	return string.format("Promise(%s)", self._state)
end

return Promise :: PromiseModule
