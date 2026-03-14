--!native
--!optimize 2

type State = number

type SettledResult<T> =
	{ status: "fulfilled", value: T } |
{ status: "rejected", reason: any }

type Callback<T> = {
	resolve: (T) -> (),
	reject: (any) -> ()
}

export type Promise<T> = {
	andThen: <U>(self: Promise<T>, fn:(T)->(U | Promise<U>)) -> Promise<U>,
	catch: (self: Promise<T>, fn:(any)->any) -> Promise<any>,
	finally: (self: Promise<T>, fn:()->()) -> Promise<T>,
	cancel: (self: Promise<T>) -> (),
	await: (self: Promise<T>) -> T,

	_state: State,
	_value: any,
	_callbacks: {Callback<any>}?
}

export type PromiseModule = {
	new: <T>(executor:(resolve:(T)->(),reject:(any)->())->()) -> Promise<T>,

	resolve: <T>(value:T) -> Promise<T>,
	reject: (err:any) -> Promise<any>,
	delay: (seconds:number) -> Promise<number>,

	all: <T>(promises:{Promise<T>}) -> Promise<{T}>,
	race: <T>(promises:{Promise<T>}) -> Promise<T>,
	any: <T>(promises:{Promise<T>}) -> Promise<T>,

	map: <T,U>(promises:{Promise<T>}, mapper:(T,number)->(U | Promise<U>)) -> Promise<{U}>,
	allSettled: <T>(promises:{Promise<T>}) -> Promise<{SettledResult<T>}>,

	try: <T>(fn:()->(T | Promise<T>)) -> Promise<T>
}

local Promise = {}::PromiseModule
Promise.__index = Promise

local PENDING:State = 0
local RESOLVED:State = 1
local REJECTED:State = 2
local CANCELLED:State = 3

local queue:{()->()} = table.create(256)
local qlen:number = 0
local flushing:boolean = false

local function flush():()
	for i:number = 1, qlen do
		local fn = queue[i]
		queue[i] = nil
		if fn then
			fn()
		end
	end
	qlen = 0
	flushing = false
end

local function schedule(fn:()->()):()
	qlen += 1
	queue[qlen] = fn

	if not flushing then
		flushing = true
		task.defer(flush)
	end
end

local function rejectPromise(promise:Promise<any>,err:any):()
	if promise._state ~= PENDING then
		return
	end
	promise._state = REJECTED
	promise._value = err
	local callbacks = promise._callbacks
	if not callbacks then
		return
	end
	promise._callbacks = nil

	for i:number=1,#callbacks do
		local cb = callbacks[i]
		schedule(function()
			cb.reject(err)
		end)
	end
end

local function resolvePromise<T>(promise:Promise<T>, value:T | Promise<T>):()
	if promise._state ~= PENDING then
		return
	end
	if typeof(value) == "table" and getmetatable(value) == Promise then
		(value :: Promise<any>)
			:andThen(function(v:any)
				resolvePromise(promise,v)
			end)
			:catch(function(e:any)
				rejectPromise(promise,e)
			end)
		return
	end
	promise._state = RESOLVED
	promise._value = value
	local callbacks = promise._callbacks
	if not callbacks then
		return
	end
	promise._callbacks = nil
	for i:number=1,#callbacks do
		local cb = callbacks[i]
		schedule(function()
			cb.resolve(value)
		end)
	end
end

function Promise.new<T>(executor:(resolve:(T)->(),reject:(any)->())->()):Promise<T>
	local self:Promise<T> = setmetatable({
		_state = PENDING,
		_value = nil,
		_callbacks = {} :: {Callback<any>}
	},Promise)

	local function resolve(v:T)
		resolvePromise(self,v)
	end
	local function reject(e:any)
		rejectPromise(self,e)
	end
	local ok,err = pcall(executor,resolve,reject)
	if not ok then
		reject(err)
	end
	return self
end

function Promise:andThen<T,U>(fn:(T)->(U | Promise<U>)):Promise<U>
	local selfPromise:Promise<T> = self
	return Promise.new(function(resolve:(U)->(),reject:(any)->())
		local function success(value:T)
			local ok,result = pcall(fn,value)
			if not ok then
				reject(result)
				return
			end
			if typeof(result) == "table" and getmetatable(result) == Promise then
				(result :: Promise<U>)
					:andThen(resolve)
					:catch(reject)
			else
				resolve(result :: U)
			end
		end
		local function fail(err:any)
			reject(err)
		end
		if selfPromise._state == RESOLVED then
			schedule(function()
				success(selfPromise._value)
			end)
		elseif selfPromise._state == REJECTED then
			schedule(function()
				fail(selfPromise._value)
			end)
		elseif selfPromise._state == PENDING then
			local list = selfPromise._callbacks
			if list then
				list[#list+1] = {
					resolve = success,
					reject = fail
				}
			end
		end
	end)
end

function Promise:catch(fn:(any)->any):Promise<any>
	return self:andThen(function(v:any)
		return v
	end,function(err:any)
		return fn(err)
	end)
end

function Promise:finally(fn:()->()):Promise<any>
	return self
		:andThen(function(v:any)
			fn()
			return v
		end)
		:catch(function(err:any)
			fn()
			error(err)
		end)
end

function Promise:cancel():()
	if self._state ~= PENDING then
		return
	end
	self._state = CANCELLED
	self._callbacks = nil
end

function Promise:await<T>():T
	if self._state == RESOLVED then
		return self._value
	end
	if self._state == REJECTED then
		error(self._value)
	end
	local thread = coroutine.running()
	self:andThen(function(v:T)
		task.spawn(thread,v)
	end)
		:catch(function(e:any)
			task.spawn(thread,nil,e)
		end)
	local value,err = coroutine.yield()
	if err then
		error(err)
	end
	return value
end

function Promise.resolve<T>(value:T):Promise<T>
	return Promise.new(function(resolve:(T)->())
		resolve(value)
	end)
end

function Promise.reject(err:any):Promise<any>
	return Promise.new(function(_,reject:(any)->())
		reject(err)
	end)
end

function Promise.delay(seconds:number):Promise<number>
	return Promise.new(function(resolve:(number)->())
		task.delay(seconds,function()
			resolve(seconds)
		end)
	end)
end

function Promise.all<T>(promises:{Promise<T>}):Promise<{T}>
	return Promise.new(function(resolve:({T})->(),reject:(any)->())
		local count = #promises
		local remaining = count
		local results:{T} = table.create(count)
		for i=1,count do
			promises[i]:andThen(function(v:T)
				results[i] = v
				remaining -= 1
				if remaining == 0 then
					resolve(results)
				end
			end):catch(reject)
		end
	end)
end

function Promise.race<T>(promises:{Promise<T>}):Promise<T>
	return Promise.new(function(resolve:(T)->(),reject:(any)->())
		for i=1,#promises do
			promises[i]
				:andThen(resolve)
				:catch(reject)
		end
	end)
end

function Promise.any<T>(promises:{Promise<T>}):Promise<T>
	return Promise.new(function(resolve:(T)->(),reject:(any)->())
		local fails:number = 0
		local total:number = #promises
		for i=1,total do
			promises[i]
				:andThen(resolve)
				:catch(function()

					fails += 1

					if fails == total then
						reject("All promises rejected")
					end

				end)
		end
	end)
end

function Promise.try<T>(fn: () -> (T | Promise<T>)): Promise<T>
	return Promise.new(function(resolve: (T) -> (), reject: (any) -> ())
		local ok, result = pcall(fn)

		if not ok then
			reject(result)
			return
		end

		if typeof(result) == "table" and getmetatable(result) == Promise then
			(result :: Promise<T>):andThen(resolve):catch(reject)
		else
			resolve(result :: T)
		end
	end)
end

function Promise.map<T, U>(promises: {Promise<T>},mapper: (T, number) -> (U | Promise<U>)): Promise<{U}>
	return Promise.new(function(resolve: ({U}) -> (), reject: (any) -> ())
		local count = #promises
		local remaining = count
		local results:{U} = table.create(count)
		if count == 0 then
			resolve(results)
			return
		end
		for i = 1, count do
			promises[i]:andThen(function(value:T)
				local ok, mapped = pcall(mapper, value, i)
				if not ok then
					reject(mapped)
					return
				end
				if typeof(mapped) == "table" and getmetatable(mapped) == Promise then
					(mapped :: Promise<U>)
						:andThen(function(v:U)
							results[i] = v
							remaining -= 1
							if remaining == 0 then
								resolve(results)
							end
						end)
						:catch(reject)
				else
					results[i] = mapped :: U
					remaining -= 1
					if remaining == 0 then
						resolve(results)
					end
				end
			end):catch(reject)
		end
	end)
end

function Promise.allSettled<T>(promises: {Promise<T>}): Promise<{SettledResult<T>}>
	return Promise.new(function(resolve: ({SettledResult<T>}) -> ())
		local count = #promises
		local remaining = count
		local results:{SettledResult<T>} = table.create(count)
		if count == 0 then
			resolve(results)
			return
		end
		for i = 1, count do
			promises[i]
				:andThen(function(v:T)
					results[i] = {
						status = "fulfilled",
						value = v
					}
					remaining -= 1
					if remaining == 0 then
						resolve(results)
					end
				end)
				:catch(function(err:any)
					results[i] = {
						status = "rejected",
						reason = err
					}
					remaining -= 1
					if remaining == 0 then
						resolve(results)
					end
				end)
		end
	end)
end

return Promise
