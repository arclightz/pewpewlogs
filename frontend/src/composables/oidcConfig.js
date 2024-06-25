export const oidcConfig = {
  authority: "https://pewpewlogs.mrdj.stream/api/proxy/openid-configuration",
  client_id: import.meta.env.VITE_OIDC_CLIENT_ID,
  redirect_uri: import.meta.env.VITE_OIDC_REDIRECT_URI,
  response_type: "code",
  scope: "openid profile email",
  post_logout_redirect_uri: import.meta.env.VITE_OIDC_POST_LOGOUT_REDIRECT_URI,
};