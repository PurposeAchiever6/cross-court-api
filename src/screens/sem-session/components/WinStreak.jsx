import React, { useState } from 'react';
import { takeWhile } from 'ramda';
import styled from 'styled-components';
import colors from 'shared/styles/constants';

const Container = styled.div`
  width: 100%;
  height: 15rem;
  position: relative;
  margin-bottom: 2rem;

  .title {
    text-transform: uppercase;
    color: ${colors.polarPlum};
    font-size: 1rem;
    margin: 0 1.2rem;
  }

  .streak {
    z-index: -1;
    background-color: ${colors.lightGrey};
    width: 100%;
    height: 8rem;
    position: absolute;
    bottom: 0;
  }

  .streak-dots {
    position: absolute;
    bottom: 1rem;
    margin-left: 1rem;
  }

  .dot {
    height: 2rem;
    width: 2rem;
    border-radius: 50%;
    display: inline-block;
    position: relative;
    margin-left: 0.5rem;
  }

  .grey {
    background-color: ${colors.grey};
  }

  .white {
    background-color: ${colors.white};
  }

  .black {
    background-color: ${colors.black};
  }

  .team-buttons {
    display: flex;
    justify-content: space-around;
    margin-top: 1rem;

    button {
      width: 9rem;
      height: 8rem;
      outline: none;
      line-height: 1.2;
      box-shadow: 0px 0px 5px 0px ${colors.lightBlackOverlay};

      p {
        margin: 0;
      }

      .plus-one {
        font-family: Space Mono;
        font-size: 4rem;
      }

      .shirt-color {
        font-size: 1rem;
      }
    }

    .black-btn {
      background-color: ${colors.black};
      border-color: ${colors.black};
      color: ${colors.white};
    }

    .white-btn {
      background-color: ${colors.white};
      border-color: ${colors.white};
      color: ${colors.black};
    }

    .in-a-row {
      height: auto;

      p {
        margin: 0;
        font-size: 1.3rem;
        text-transform: uppercase;
      }

      .subtitle {
        font-weight: 500;
      }

      .white {
        background-color: ${colors.white};
        color: ${colors.black};
      }

      .black {
        background-color: ${colors.black};
        color: ${colors.white};
      }
    }
  }
`;

const WinStreak = () => {
  const [streak, setStreak] = useState([]);
  const [threeInARow, setThreeInARow] = useState();

  const resetStreak = () => {
    setThreeInARow();
    setStreak([]);
  };

  const addWin = winner => {
    if (takeWhile(item => item === winner, streak).length === 2) {
      setThreeInARow(winner);
      setTimeout(() => {
        resetStreak();
      }, 3000);
    }
    setStreak([winner, ...streak]);
  };

  return (
    <Container>
      <p className="title">win streak</p>
      <div className="team-buttons">
        <button className="black-btn" type="button" onClick={() => addWin('black')}>
          {threeInARow === 'black' ? (
            <div className="in-a-row black">
              <p>black won</p>
              <p className="subtitle"> 3 in a row!</p>
            </div>
          ) : (
            <>
              <p className="plus-one">+1</p>
              <p className="shirt-color">white</p>
            </>
          )}
        </button>
        <button className="white-btn" type="button" onClick={() => addWin('white')}>
          {threeInARow === 'white' ? (
            <div className="in-a-row white">
              <p>white won</p>
              <p className="subtitle"> 3 in a row!</p>
            </div>
          ) : (
            <>
              <p className="plus-one">+1</p>
              <p className="shirt-color">white</p>
            </>
          )}
        </button>
      </div>
      <div className="streak">
        <div className="streak-dots">
          {[0, 1, 2].map(index => {
            return streak.length > index ? (
              <span key={`dot-${index}`} className={`dot ${streak[index]}`} />
            ) : (
              <span key={`dot-${index}`} className="dot grey" />
            );
          })}
        </div>
      </div>
    </Container>
  );
};

export default WinStreak;