import React from 'react';

const HomeVideo = () => (
  <section>
    <video
      className="w-full"
      src="/home.mp4"
      autoPlay
      muted
      playsInline
      controls
      loop
      type="video/mp4"
    />
  </section>
);

export default HomeVideo;