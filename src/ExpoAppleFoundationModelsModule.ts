import { NativeModule, requireNativeModule } from "expo";
import {
    ExpoAppleFoundationModels,
    ExpoAppleFoundationModelsEvents,
    // ToolInvocationEvent,
} from "./ExpoAppleFoundationModels.types";
// import { EventSubscription } from "react-native";

export type ExpoAppleFoundationModelsType = ExpoAppleFoundationModels &
    ExpoAppleFoundationModelsEvents;

// export function addToolInvocationListener(
//     listener: (event: ToolInvocationEvent) => void
// ): EventSubscription {
//     return ExpoAppleFoundationModelsModule.addListener(
//         "onChangeToolInvocation",
//         listener
//     );
// }

declare class ExpoAppleFoundationModelsModule extends NativeModule<ExpoAppleFoundationModelsType> {}

export default requireNativeModule<ExpoAppleFoundationModelsModule>(
    "FoundationModels"
);
