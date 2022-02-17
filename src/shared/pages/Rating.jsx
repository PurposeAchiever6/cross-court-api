import React, { useState, useEffect } from 'react';
import { useDispatch } from 'react-redux';
import { useHistory, useLocation } from 'react-router-dom';
import styled from 'styled-components';

import ROUTES from 'shared/constants/routes';
import BasketballSvg from 'shared/components/svg/BasketballSvg';
import PrimaryButton from 'shared/components/buttons/PrimaryButton';
import BackButton from 'shared/components/BackButton';
import OnboardingTour from 'shared/components/OnboardingTour';
import { isOnboardingTourEnable, disableOnboardingTour } from 'shared/utils/onboardingTour';

import { updateSkillRatingInit } from '../../screens/auth/actionCreators';

const Circle = styled.div`
  border: 2px solid white;
  background-color: transparent;
  height: 30px;
  border-radius: 50%;
  width: 30px;
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
`;

const ALLOWED_PATHS = [ROUTES.MYACCOUNT, ROUTES.SIGNUP];

const RATINGS = [
  {
    value: '1',
    name: 'Rookie',
    description:
      'Lotta heart. Hustler. Not much basketball experience, but ready to do whatever ' +
      'the team needs to succeed. Here for the vibes, the sweat, and lockdown defense.',
  },
  {
    value: '2',
    name: 'Rising Star',
    description:
      'Love the game. Not a difference maker yet, but looking to improve my skills and quiet ' +
      'the non-believers.',
  },
  {
    value: '3',
    name: 'Vet',
    description:
      'Show flashes. Little inconsistent due to lack of play, but can hold my own against most ' +
      'competition. Will be an MVP in no time.',
  },
  {
    value: '4',
    name: 'All Star',
    description:
      'Built different. Played competitively within the last 20 years at a D2/3 university or ' +
      'was a varsity standout. Playmaker.',
  },
  {
    value: '5',
    name: 'MVP',
    description:
      'Like Mike. Walking bucket as the kids say. Played D1 or professionally within the last ' +
      '20 years. Ball is/was life.',
  },
];

const Rating = () => {
  const [skillRating, setSkillRating] = useState(null);
  const [isEdit, setIsEdit] = useState(false);
  const dispatch = useDispatch();
  const location = useLocation();
  const history = useHistory();

  const updateSkillRatingAction = () => dispatch(updateSkillRatingInit({ skillRating, isEdit }));

  const handleClick = () => {
    updateSkillRatingAction();
  };

  useEffect(() => {
    if (!ALLOWED_PATHS.includes(location?.state?.from)) history.push(ROUTES.HOME);
    setIsEdit(location?.state?.isEdit ?? false);
    setSkillRating(location?.state?.currentValue ?? null);
  }, [location, history]);

  return (
    <div className="flex color-cc-black justify-center p-4 md:p-8">
      <div className="flex flex-col">
        {isEdit && <BackButton className="my-6 md:mt-0" />}
        <h1 className="font-shapiro95_super_wide text-xl md:text-3xl text-center mt-4">
          SKILL ASSESSMENT SURVEY
        </h1>
        <h2 className="my-8 md:text-lg max-w-7xl text-center">
          To give you the best experience possible, we ask that you choose one of the following
          descriptions of your current skill level so we are able to surround you with players of
          similar ability.
        </h2>
        <div className="text-white self-center">
          {RATINGS.map((rating) => (
            <div className="flex my-1 max-w-6xl" key={rating.value}>
              <div className="flex items-center bg-cc-black p-4 md:px-8 md:py-4">
                <span className="w-4 text-center">{rating.value}</span>
                <span className="hidden sm:block ml-5 uppercase w-32">{rating.name}</span>
              </div>
              <div className="flex mx-1 bg-cc-black p-4 text-sm md:text-base w-full">
                {rating.description}
              </div>
              <div
                className="relative flex justify-center items-center bg-cc-black cursor-pointer p-4 sm:p-7 md:px-10 md:py-8"
                onClick={() => setSkillRating(rating.value)}
              >
                <BasketballSvg
                  className={`w-6 h-6 ${skillRating === rating.value ? 'visible' : 'invisible'}`}
                />
                <Circle />
              </div>
            </div>
          ))}
        </div>
        <PrimaryButton
          id="rating-btn"
          disabled={!skillRating}
          className="my-6"
          onClick={handleClick}
        >
          {isEdit ? 'SAVE' : 'SIGN UP'}
        </PrimaryButton>
        {!isEdit && (
          <OnboardingTour
            id="onboarding-tour-rating"
            enabled={isOnboardingTourEnable('onboarding-tour-rating')}
            onExit={() => {
              disableOnboardingTour('onboarding-tour-rating');
              window.scrollTo({ top: 0 });
            }}
            steps={[
              {
                element: '#rating-btn',
                intro:
                  'Choose a description that most describes your current skill level and tap <strong>SIGN UP</strong> to receive your account verification email. Verify your email and a free session credit will be placed in your account. Make sure to check your other email folders if it’s not in your inbox. Side note: You are able to edit your skill level later.',
              },
            ]}
          />
        )}
      </div>
    </div>
  );
};

export default Rating;