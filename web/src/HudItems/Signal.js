// @flow

import * as React from 'react';
import './Signal.css';

type Props = {
  strength: number
};

function capStrength(value: number) {
  if (value <= 0) return 0;
  if (value >= 100) return 100;

  return value;
}

function Signal(props: Props) {
  const strength = capStrength(props.strength);

  return (
    <div className="Signal">
      <h3>{strength}</h3>
    </div>
  );
}

export default Signal;
