import React from 'react';
import PropTypes from 'prop-types';
import styled from 'styled-components';
import { Link } from 'react-router-dom';
import { isNil } from 'ramda';
import { hourRange, shortSessionDate, urlFormattedDate } from 'shared/utils/date';
import AlternativeButton from 'shared/components/AlternativeButton';
import ImageSvg from 'shared/components/svg/Image.svg';
import colors from 'shared/styles/constants';

const PastSessionsContainer = styled.div`
  padding: 3rem;

  h3 {
    font-size: 1.75rem;
    font-weight: 500;
    margin: 0 0 2rem 0;
  }

  .sessions-container {
    display: grid;
    grid-template-columns: repeat(6, 1fr);
    grid-template-rows: repeat(1, 1fr);
    grid-column-gap: 2rem;
    grid-row-gap: 2rem;

    .session-item {
      display: flex;
      flex-direction: column;
      box-shadow: 0px 2px 20px rgba(0, 0, 0, 0.15);

      .no-image {
        width: 100%;
        height: 15rem;
        display: flex;
        justify-content: center;
        align-items: center;
        color: ${colors.polarPlum};
        background-color: ${colors.lightGrey};

        svg {
          width: 6rem;
        }
      }

      img {
        max-width: 375px;
      }

      .date {
        background-color: #f8f8f8;
        color: #bbbecd;
        font-style: italic;
        font-weight: bold;
        font-size: 18px;
        line-height: 22px;
        letter-spacing: 0.1em;
        text-transform: uppercase;
        padding: 1rem;
      }

      .details {
        display: flex;
        flex-direction: column;
        padding: 1.5rem;

        .time {
          font-family: Untitled Sans;
          font-style: normal;
          font-weight: bold;
          font-size: 18px;
          line-height: 22px;
          letter-spacing: 0.1em;
          color: #000000;
          margin-bottom: 0.5rem;
        }

        .location {
          font-size: 18px;
          line-height: 22px;
          letter-spacing: 0.1em;
          text-transform: uppercase;
          margin-bottom: 2rem;
        }

        .btn-alt {
          color: #000;
          border: 1px solid #000;
          font-weight: 500;
          font-size: 16px;
          line-height: 20px;
          width: 100%;
        }
      }
    }
  }
`;

const PastSessions = ({ sessions }) => (
  <PastSessionsContainer>
    <h3>Past Sessions</h3>
    <div className="sessions-container">
      {sessions.map(session => (
        <div className="session-item" key={session.id}>
          {isNil(session.session.location.imageUrl) ? (
            <div className="no-image">
              <ImageSvg />
            </div>
          ) : (
            <img src={session.session.location.imageUrl} alt="Session" />
          )}
          <span className="date">{shortSessionDate(session.date)}</span>
          <div className="details">
            <span className="time">{hourRange(session.session.time)}</span>
            <span className="location">{session.session.location.name}</span>
            <Link to={`/session/${session.session.id}/${urlFormattedDate(session.date)}`}>
              <AlternativeButton className="btn-alt">See Details</AlternativeButton>
            </Link>
          </div>
        </div>
      ))}
    </div>
  </PastSessionsContainer>
);

PastSessions.propTypes = {
  sessions: PropTypes.arrayOf(PropTypes.object).isRequired,
};

export default PastSessions;