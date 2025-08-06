import { NativeModule, requireNativeModule } from 'expo';

import { ExpoAppleFoundationModelsModuleEvents } from './ExpoAppleFoundationModels.types';

declare class ExpoAppleFoundationModelsModule extends NativeModule<ExpoAppleFoundationModelsModuleEvents> {
  PI: number;
  hello(): string;
  setValueAsync(value: string): Promise<void>;
}

// This call loads the native module object from the JSI.
export default requireNativeModule<ExpoAppleFoundationModelsModule>('ExpoAppleFoundationModels');
