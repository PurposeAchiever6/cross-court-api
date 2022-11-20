module Api
  module V1
    class ApiController < ApplicationController
      include Api::Concerns::ActAsApiRequest
      include DeviseTokenAuth::Concerns::SetUserByToken

      layout false
      respond_to :json

      rescue_from Exception,                                   with: :render_error_exception
      rescue_from ActiveRecord::RecordNotFound,                with: :render_not_found
      rescue_from ActiveRecord::RecordInvalid,                 with: :render_record_invalid
      rescue_from ActionController::RoutingError,              with: :render_not_found
      rescue_from AbstractController::ActionNotFound,          with: :render_not_found
      rescue_from ActionController::ParameterMissing,          with: :render_parameter_missing
      rescue_from InvalidDateException,                        with: :render_custom_exception
      rescue_from NotEnoughCreditsException,                   with: :render_custom_exception
      rescue_from UnauthorizedException,                       with: :render_custom_exception
      rescue_from InvalidActionException,                      with: :render_custom_exception
      rescue_from WrongParameterException,                     with: :render_custom_exception
      rescue_from FullSessionException,                        with: :render_custom_exception
      rescue_from PaymentException,                            with: :render_custom_exception
      rescue_from PromoCodeInvalidException,                   with: :render_custom_exception
      rescue_from SubscriptionException,                       with: :render_custom_exception
      rescue_from ClaimFreeSessionException,                   with: :render_custom_exception
      rescue_from UserNotInWaitlistException,                  with: :render_custom_exception
      rescue_from UserDidNotVoteSessionException,              with: :render_custom_exception
      rescue_from UserFlaggedException,                        with: :render_custom_exception
      rescue_from UserSkillRatingRequireReviewException,       with: :render_custom_exception
      rescue_from SessionInvalidDateException,                 with: :render_custom_exception
      rescue_from SessionNotComingSoonException,               with: :render_custom_exception
      rescue_from SubscriptionHasSameProductException,         with: :render_custom_exception
      rescue_from PaymentMethodHasActiveSubscriptionException, with: :render_custom_exception
      rescue_from SessionIsOutOfSkillLevelException,           with: :render_custom_exception
      rescue_from SubscriptionIsNotActiveException,            with: :render_custom_exception
      rescue_from SubscriptionAlreadyCanceledException,        with: :render_custom_exception
      rescue_from SubscriptionInvalidPauseMonthsException,     with: :render_custom_exception
      rescue_from SubscriptionIsNotPausedException,            with: :render_custom_exception
      rescue_from MaximumNumberOfPausesReachedException,       with: :render_custom_exception
      rescue_from ReserveTeamNotAllowedException,              with: :render_custom_exception
      rescue_from ReserveTeamMismatchException,                with: :render_custom_exception
      rescue_from SessionOnlyForMembersException,              with: :render_custom_exception
      rescue_from ChargeUserException,                         with: :render_custom_exception
      rescue_from ShootingMachineSessionMismatchException,     with: :render_custom_exception
      rescue_from ShootingMachineInvalidSessionException,      with: :render_custom_exception
      rescue_from ShootingMachineAlreadyReservedException,     with: :render_custom_exception
      rescue_from UserBookedSessionsLimitPerDayException,      with: :render_custom_exception
      rescue_from NotEnoughScoutingCreditsException,           with: :render_custom_exception
      rescue_from InvalidSessionForScoutingException,          with: :render_custom_exception
      rescue_from Stripe::StripeError,                         with: :render_custom_exception
      rescue_from SessionGuestsException,                      with: :render_custom_exception

      def status
        render json: { online: true }
      end

      def render_error(status, message)
        render json: { error: message }, status: status
      end

      private

      def render_error_exception(exception)
        raise exception if Rails.env.test?

        logger.error(exception)
        Rollbar.error(exception)

        return if performed?

        render json: { error: I18n.t('api.errors.server') }, status: :internal_server_error
      end

      def render_not_found(exception)
        logger.info(exception) # for logging
        render json: { error: I18n.t('api.errors.not_found') }, status: :not_found
      end

      def render_record_invalid(exception)
        logger.info(exception) # for logging
        render json: { errors: exception.record.errors.as_json }, status: :bad_request
      end

      def render_parameter_missing(exception)
        logger.info(exception) # for logging
        render json: { error: I18n.t('api.errors.missing_param') }, status: :unprocessable_entity
      end

      def render_custom_exception(exception)
        logger.error(exception)
        render json: { error: exception.message }, status: :bad_request
      end
    end
  end
end
