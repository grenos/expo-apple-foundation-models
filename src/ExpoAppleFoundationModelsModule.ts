import { NativeModule, requireNativeModule } from "expo";

import { ExpoAppleFoundationModels } from "./ExpoAppleFoundationModels.types";

declare class ExpoAppleFoundationModelsModule extends NativeModule<ExpoAppleFoundationModels> {
    supportedEvents(): [string];
    isFoundationModelsEnabled(): Promise<string>;
    configureSession(config: any): Promise<boolean>;
    generateStructuredOutput(options: any): Promise<any>;
    generateText(options: any): Promise<any>;
    resetSession(): Promise<boolean>;
    generateWithTools(options: any): Promise<any>;
}

export default requireNativeModule<ExpoAppleFoundationModelsModule>(
    "FoundationModels"
);
