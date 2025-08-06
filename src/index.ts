// Reexport the native module. On web, it will be resolved to ExpoAppleFoundationModelsModule.web.ts
// and on native platforms to ExpoAppleFoundationModelsModule.ts
export { default } from "./ExpoAppleFoundationModelsModule";
export * from "./ExpoAppleFoundationModels.types";
