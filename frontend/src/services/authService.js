import { UserManager, WebStorageStateStore } from 'oidc-client-ts';
import { oidcConfig } from '../composables/oidcConfig';

const userManager = new UserManager({
  ...oidcConfig,
  userStore: new WebStorageStateStore({ store: window.localStorage }),
});

export const login = () => userManager.signinRedirect();

export const handleCallback = async () => {
  try {
    const user = await userManager.signinRedirectCallback();
    console.log('Logged in user:', user);
    return user;
  } catch (err) {
    console.error('Error handling callback:', err);
    throw err; // Re-throw the error for the caller to handle
  }
};

export const logout = () => userManager.signoutRedirect();

export const getUser = async () => {
  try {
    return await userManager.getUser();
  } catch (err) {
    console.error('Error getting user:', err);
    return null;
  }
};

// Add a function to get the access token
export const getAccessToken = async () => {
  const user = await getUser();
  return user?.access_token;
};

// Add a function to check if the user is authenticated
export const isAuthenticated = async () => {
  const user = await getUser();
  return !!user && !user.expired;
};
