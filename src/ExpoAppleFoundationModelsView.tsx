import { requireNativeView } from 'expo';
import * as React from 'react';

import { ExpoAppleFoundationModelsViewProps } from './ExpoAppleFoundationModels.types';

const NativeView: React.ComponentType<ExpoAppleFoundationModelsViewProps> =
  requireNativeView('ExpoAppleFoundationModels');

export default function ExpoAppleFoundationModelsView(props: ExpoAppleFoundationModelsViewProps) {
  return <NativeView {...props} />;
}
