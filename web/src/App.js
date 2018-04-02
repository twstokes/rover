// @flow

import React, { Component } from 'react';
import Video from './Video';
import Hud from './Hud';

import './App.css';

class App extends Component<{||}> {
  render() {
    return (
      <div className="App">
        <Video
          url="http://cameras.tannerstokes.com/cam/2/stream"
          alt="Camera Stream"
        />
        <Hud />
      </div>
    );
  }
}

export default App;
