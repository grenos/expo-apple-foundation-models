import { registerWebModule, NativeModule } from 'expo';

import { ExpoAppleFoundationModelsModuleEvents } from './ExpoAppleFoundationModels.types';

class ExpoAppleFoundationModelsModule extends NativeModule<ExpoAppleFoundationModelsModuleEvents> {
  PI = Math.PI;
  async setValueAsync(value: string): Promise<void> {
    this.emit('onChange', { value });
  }
  hello() {
    return 'Hello world! 👋';
  }
}

export default registerWebModule(ExpoAppleFoundationModelsModule, 'ExpoAppleFoundationModelsModule');
