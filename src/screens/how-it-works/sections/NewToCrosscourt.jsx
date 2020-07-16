import React, { useState } from 'react';
import ReactPlayer from 'react-player';
import ReactModal from 'react-modal';

import useWindowSize from 'shared/hooks/useWindowSize';
import { size } from 'shared/styles/mediaQueries';
import PlaySvg from 'shared/components/svg/PlaySvg';

const NewToCrosscourt = () => {
  const [showModal, setShowModal] = useState(false);
  const { width: windowSize } = useWindowSize();

  const modalStyle = {
    overlay: {
      display: 'flex',
      justifyContent: 'center',
      alignItems: 'center',
      backgroundColor: 'rgba(0, 0, 0, 0.75)',
      zIndex: 100,
    },
    content: {
      top: '50%',
      left: '50%',
      right: 'auto',
      bottom: 'auto',
      border: 'none',
      borderRadius: '0',
      transform: 'translate(-50%, -50%)',
      background: 'none',
      padding: 0,
      width: '80%',
      height: windowSize < size.desktop ? '25%' : '70%',
    },
  };
  return (
    <section className="new-to-crosscourt section-block text-white">
      <section className="title-block">
        <h2 className="title-1 shapiro97_air_extd">NEW TO</h2>
        <p className="title-2 shapiro95_super_wide">CROSSCOURT?</p>
      </section>
      <a
        className="ar-button check-it-out"
        onClick={e => {
          e.preventDefault();
          setShowModal(true);
        }}
        href="#modal"
      >
        <div className="ar-button-inner">
          <PlaySvg />
          <span className="text">CHECK IT OUT</span>
        </div>
      </a>
      <ReactModal
        shouldCloseOnOverlayClick
        style={modalStyle}
        onRequestClose={() => setShowModal(false)}
        isOpen={showModal}
      >
        <ReactPlayer
          controls
          playing
          width="100%"
          height="100%"
          url="https://player.vimeo.com/video/438000525?title=0&byline=0&portrait=0&playsinline=0&autopause=0&app_id=122963"
        />
      </ReactModal>
    </section>
  );
};

export default NewToCrosscourt;