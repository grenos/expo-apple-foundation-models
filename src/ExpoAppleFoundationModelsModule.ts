import { NativeModule, requireNativeModule } from "expo";
import {
    ExpoAppleFoundationModels,
    ExpoAppleFoundationModelsEvents,
} from "./ExpoAppleFoundationModels.types";

type ExpoAppleFoundationModelsType = ExpoAppleFoundationModels &
    ExpoAppleFoundationModelsEvents;

declare class ExpoAppleFoundationModelsModule extends NativeModule<ExpoAppleFoundationModelsType> {}

export default requireNativeModule<ExpoAppleFoundationModelsModule>(
    "FoundationModels"
);
