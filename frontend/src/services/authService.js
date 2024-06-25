import { UserManager, WebStorageStateStore } from 'oidc-client-ts';
import { oidcConfig } from '../composables/oidcConfig'; // Import the configuration

const userManager = new UserManager({
  ...oidcConfig,
  userStore: new WebStorageStateStore({ store: window.localStorage }),
});

export const login = () => {
  userManager.signinRedirect();
};

export const handleCallback = async () => {
  try {
    const user = await userManager.signinRedirectCallback();
    console.log('Logged in user:', user);
  } catch (err) {
    console.error('Error handling callback:', err);
  }
};

export const logout = () => {
  userManager.signoutRedirect();
};

export const getUser = async () => {
  try {
    const user = await userManager.getUser();
    return user;
  } catch (err) {
    console.error('Error getting user:', err);
    return null;
  }
};
