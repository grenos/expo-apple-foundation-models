import * as React from 'react';

import { ExpoAppleFoundationModelsViewProps } from './ExpoAppleFoundationModels.types';

export default function ExpoAppleFoundationModelsView(props: ExpoAppleFoundationModelsViewProps) {
  return (
    <div>
      <iframe
        style={{ flex: 1 }}
        src={props.url}
        onLoad={() => props.onLoad({ nativeEvent: { url: props.url } })}
      />
    </div>
  );
}
