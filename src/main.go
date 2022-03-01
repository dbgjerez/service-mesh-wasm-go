package main

import (
	"time"

	"github.com/tetratelabs/proxy-wasm-go-sdk/proxywasm"
	"github.com/tetratelabs/proxy-wasm-go-sdk/proxywasm/types"
)

func main() {
	proxywasm.SetVMContext(&vmContext{})
}

type vmContext struct {
	types.DefaultVMContext
}

// Own context overriding types.DefaultVMContext
func (*vmContext) NewPluginContext(contextID uint32) types.PluginContext {
	return &wasmContext{}
}

type wasmContext struct {
	// Embed the default plugin context here,
	// so that we don't need to reimplement all the methods.
	types.DefaultPluginContext
	contextID uint32
}

// Override types.DefaultPluginContext.
func (ctx *wasmContext) OnPluginStart(pluginConfigurationSize int) types.OnPluginStartStatus {
	proxywasm.LogInfo("OnPluginStart from Go!" + time.Now().GoString())

	return types.OnPluginStartStatusOK
}

// Override types.DefaultPluginContext.
func (*wasmContext) NewHttpContext(uint32) types.HttpContext { return &types.DefaultHttpContext{} }
