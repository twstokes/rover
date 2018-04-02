// @flow

import * as React from 'react';

import Signal from './HudItems/Signal';
import Throttle from './HudItems/Throttle';
import Pitch from './HudItems/Pitch';
import Roll from './HudItems/Roll';
import Steering from './HudItems/Steering';
import Compass from './HudItems/Compass';
import Accelerometer from './HudItems/Accelerometer';
import Lights from './HudItems/Lights';

import './Hud.css';

type Props = {
  // signalStrength: number
};

type State = {
  signalStrength: number
};

class Hud extends React.Component<Props, State> {
  // foo: number

  constructor(props: Props) {
    super(props);
    this.state = { signalStrength: 0 };
  }

  componentDidMount() {
    // this.foo = setInterval(
    //   () => this.tick(),
    //   1000
    // );
  }

  // tick() {
  //   this.setState((prevState, _) => ({
  //     signalStrength: prevState.signalStrength += 1
  //   }));
  // }

  render() {
    return (
      <div className="Hud">
        <Signal strength={this.state.signalStrength} />
        <Throttle />
        <Pitch />
        <Roll />
        <Steering />
        <Compass />
        <Accelerometer />
        <Lights />
      </div>
    );
  }
}

export default Hud;
