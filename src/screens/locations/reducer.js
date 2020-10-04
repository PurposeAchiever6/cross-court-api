import { createSelector } from 'reselect';
import {
  INITIAL_LOAD_INIT,
  INITIAL_LOAD_SUCCESS,
  INITIAL_LOAD_FAILURE,
  GET_SESSIONS_BY_LOCATION_INIT,
  GET_SESSIONS_BY_LOCATION_SUCCESS,
  GET_SESSIONS_BY_LOCATION_FAILURE,
  GET_SESSIONS_BY_DATE_INIT,
  GET_SESSIONS_BY_DATE_SUCCESS,
  GET_SESSIONS_BY_DATE_FAILURE,
  SET_SELECTED_DATE,
} from './actionTypes';

const initialState = {
  error: '',
  pageLoading: false,
  sessionsLoading: false,
  availableLocations: [],
  availableSessions: [],
  selectedLocation: null,
  selectedDate: new Date(),
};

export default (state = initialState, action) => {
  switch (action.type) {
    case INITIAL_LOAD_INIT:
      return {
        ...state,
        pageLoading: true,
        error: '',
      };
    case INITIAL_LOAD_SUCCESS:
      return {
        ...state,
        pageLoading: false,
        availableLocations: [...action.payload.availableLocations],
        availableSessions: [...action.payload.availableSessions],
      };
    case INITIAL_LOAD_FAILURE:
      return { ...state, error: action.error, pageLoading: false };
    case GET_SESSIONS_BY_LOCATION_INIT:
      return {
        ...state,
        selectedLocation: action.payload.locationId,
        selectedDate: new Date(),
        sessionsLoading: true,
        error: '',
      };
    case GET_SESSIONS_BY_DATE_SUCCESS:
    case GET_SESSIONS_BY_LOCATION_SUCCESS:
      return {
        ...state,
        sessionsLoading: false,
        availableSessions: [...action.payload.availableSessions],
      };
    case GET_SESSIONS_BY_DATE_FAILURE:
    case GET_SESSIONS_BY_LOCATION_FAILURE:
      return { ...state, error: action.error, sessionsLoading: false };
    case GET_SESSIONS_BY_DATE_INIT:
      return { ...state, selectedDate: action.payload.date, sessionsLoading: true };
    case SET_SELECTED_DATE:
      return { ...state, selectedDate: action.payload.date };
    default:
      return state;
  }
};

const getLocations = state => state.locations;

export const getPageLoading = createSelector(getLocations, locations => locations.pageLoading);

export const getError = createSelector(getLocations, locations => locations.error);

export const getAvailableLocations = createSelector(
  getLocations,
  locations => locations.availableLocations
);

export const getAvailableSessions = createSelector(
  getLocations,
  locations => locations.availableSessions
);

export const getSelectedLocation = createSelector(
  getLocations,
  locations => locations.selectedLocation
);

export const getSessionsLoading = createSelector(
  getLocations,
  locations => locations.sessionsLoading
);

export const getSelectedDate = createSelector(
  getLocations,
  locations => new Date(locations.selectedDate)
);