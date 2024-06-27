import createKindeClient from '@kinde-oss/kinde-auth-pkce-js';
import state from './state';

const initializeKinde = async () => {
  const kinde = await createKindeClient({
    client_id: '9fe6adb9e3214aa69aa1be5248ed0bdf',
    domain: 'https://arclightsec-warpcore.eu.kinde.com',
    redirect_uri: `${window.location.origin}/auth/callback`,
    on_redirect_callback: (user, appState) => {
      console.log({ user, appState });
      state.user = user;
    }
  });
  
  state.kinde = kinde;
  return kinde;
};

const getUser = async () => {
  return state.user;
}

const handleCallback = async () => {
  const user = await state.kinde.handleRedirectCallback();
  state.user = user;
};

export { initializeKinde, getUser, handleCallback };
