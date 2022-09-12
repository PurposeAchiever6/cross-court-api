import React, { useState } from 'react';
import PropTypes from 'prop-types';

import InputSelectField from 'shared/components/InputSelectField';
import Modal from 'shared/components/Modal';
import PrimaryButton from 'shared/components/buttons/PrimaryButton';
import { subscriptionPeriodFormattedDate } from 'shared/utils/date';

const OPTIONS = [
  { value: 1, label: '1' },
  { value: 2, label: '2' },
];

export const PauseMembershipModal = ({
  isOpen,
  closeHandler,
  activeSubscription,
  pauseSubscriptionAction,
}) => {
  const [months, setMonths] = useState(null);

  const onPauseClick = () => {
    pauseSubscriptionAction(months);
    closeHandler();
  };

  return (
    <Modal isOpen={isOpen} closeHandler={closeHandler} title="Enter Offseason">
      <div className="flex flex-col items-center justify-center">
        <p className="mb-4">
          {`You may freeze your membership for a minimum of 1 month or a maximum of 2
          months up to ${activeSubscription.pausesPerYear} times per year. Once the freeze period ends, your membership will
          revert to regular monthly billing. No payments will be made during the freeze period.`}
        </p>
        <p className="mb-4">
          {`Your membership will freeze at the end of your current billing period, ${subscriptionPeriodFormattedDate(
            activeSubscription.currentPeriodEnd
          )}.`}
        </p>
        <p className="mb-4">
          Please note, you will not be able to reserve a session once your membership pause starts.
        </p>
        <InputSelectField
          name="subscription-pause-months"
          placeholder="Months"
          options={OPTIONS}
          onChange={({ value }) => setMonths(value)}
          className="w-1/2 sm:w-2/5 mb-6"
          formik={false}
        />
        <p className="mb-6">If vou're sure you'd like to pause your membership, confirm below.</p>
        <PrimaryButton disabled={!months} onClick={onPauseClick}>
          Pause Membership
        </PrimaryButton>
      </div>
    </Modal>
  );
};

PauseMembershipModal.propTypes = {
  isOpen: PropTypes.bool.isRequired,
  closeHandler: PropTypes.func.isRequired,
  activeSubscription: PropTypes.shape().isRequired,
  pauseSubscriptionAction: PropTypes.func.isRequired,
};

export default PauseMembershipModal;