// @flow

import * as React from 'react';
import './Video.css';

type Props = {
  url: string,
  alt: string
};

class Video extends React.Component<Props> {
  render() {
    return (
      <div className="Video">
        <img src={this.props.url} alt={this.props.alt} />
      </div>
    );
  }
}

export default Video;
