import React from 'react';
import PropTypes from 'prop-types';
import { Formik, Form } from 'formik';
import * as Yup from 'yup';

import InputTextField from 'shared/components/InputTextField';
import InputPhoneField from 'shared/components/InputPhoneField';
import PrimaryButton from 'shared/components/buttons/PrimaryButton';

const initialValues = {
  firstName: '',
  lastName: '',
  phoneNumber: '',
  email: '',
};

const validationSchema = Yup.object().shape({
  firstName: Yup.string().required('Required'),
  lastName: Yup.string().required('Required'),
  phoneNumber: Yup.string().required('Required'),
  email: Yup.string().required('Required'),
});

const AddGuestStep = ({ sessionInformation, onGuestAdded }) => (
  <div className="flex flex-col">
    <div className="flex justify-between -mx-1">
      {sessionInformation.map((info, i) => (
        <div className="px-1" key={`modal-info-${i}`}>
          <p className="uppercase font-shapiro95_super_wide text-sm">{info.title}</p>
          <p className="uppercase font-shapiro45_welter_extd text-xs">{info.value}</p>
        </div>
      ))}
    </div>
    <p className="my-4 text-sm text-center">
      Easily invite a friend to the session above. Once you enter in your guest's contact
      information and click ADD, they will receive a text message with a code to show their Session
      Experience Manager upon arrival.
    </p>
    <Formik
      validateOnChange={false}
      validateOnBlur={false}
      initialValues={initialValues}
      onSubmit={(values) => {
        onGuestAdded(values);
      }}
      validationSchema={validationSchema}
    >
      {({ isSubmitting }) => (
        <Form className="font-shapiro95_super_wide flex flex-col px-4 self-center mt-4">
          <InputTextField label="First Name*" name="firstName" className="mb-2 md:mb-5" />
          <InputTextField label="Last Name*" name="lastName" className="mb-2 md:mb-5" />
          <InputPhoneField label="Phone Number*" name="phoneNumber" className="mb-2 md:mb-5" />
          <InputTextField label="Email*" name="email" className="mb-2 md:mb-5" />
          <PrimaryButton loading={isSubmitting} className="text-center self-center" type="submit">
            ADD
          </PrimaryButton>
        </Form>
      )}
    </Formik>
  </div>
);

AddGuestStep.propTypes = {
  sessionInformation: PropTypes.arrayOf(PropTypes.shape()).isRequired,
  onGuestAdded: PropTypes.func.isRequired,
};

export default AddGuestStep;