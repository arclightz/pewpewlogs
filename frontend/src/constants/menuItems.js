// frontend/src/constants/menuItems.js

// Define common SVG icon paths
const SVG_ICONS = {
  dashboard: 'm2.25 12 8.954-8.955c.44-.439 1.152-.439 1.591 0L21.75 12M4.5 9.75v10.125c0 .621.504 1.125 1.125 1.125H9.75v-4.875c0-.621.504-1.125 1.125-1.125h2.25c.621 0 1.125.504 1.125 1.125V21h4.125c.621 0 1.125-.504 1.125-1.125V9.75M8.25 21h8.25', // Home icon
  sessions: 'M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-3 7h3m-3 4h3m-6-4h.01M9 16h.01', // Document icon
  weapons: 'M15.362 5.214A8.252 8.252 0 0 1 12 21 8.25 8.25 0 0 1 6.038 7.047 8.287 8.287 0 0 0 9 9.601a8.983 8.983 0 0 1 3.361-6.867 8.21 8.21 0 0 0 3 2.48Z M12 18a3.75 3.75 0 0 0 .495-7.468 5.99 5.99 0 0 0-1.925 3.547 5.975 5.975 0 0 1-2.133-1.001A3.75 3.75 0 0 0 12 18Z', // Adjustments/Tools icon
  statistics: 'M7.5 14.25v2.25m3-4.5v4.5m3-6.75v6.75m3-9v9M6 20.25h12A2.25 2.25 0 0 0 20.25 18V6A2.25 2.25 0 0 0 18 3.75H6A2.25 2.25 0 0 0 3.75 6v12A2.25 2.25 0 0 0 6 20.25Z', // Chart pie icon
  ranges: 'M9 6.75V15m6-6v8.25m.503 3.498 4.875-2.437c.381-.19.622-.58.622-1.006V4.82c0-.836-.88-1.38-1.628-1.006l-3.869 1.934c-.317.159-.69.159-1.006 0L9.503 3.252a1.125 1.125 0 0 0-1.006 0L3.622 5.689C3.24 5.88 3 6.27 3 6.695V19.18c0 .836.88 1.38 1.628 1.006l3.869-1.934c.317-.159.69-.159 1.006 0l4.994 2.497c.317.158.69.158 1.006 0Z', // Location icon
  profile: 'M10 8a3 3 0 1 0 0-6 3 3 0 0 0 0 6ZM3.465 14.493a1.23 1.23 0 0 0 .41 1.412A9.957 9.957 0 0 0 10 18c2.31 0 4.438-.784 6.131-2.1.43-.333.604-.903.408-1.41a7.002 7.002 0 0 0-13.074.003Z', 
  logout: 'M8.25 9V5.25A2.25 2.25 0 0 1 10.5 3h6a2.25 2.25 0 0 1 2.25 2.25v13.5A2.25 2.25 0 0 1 16.5 21h-6a2.25 2.25 0 0 1-2.25-2.25V15m-3 0-3-3m0 0 3-3m-3 3H15', // Logout icon
  login: 'M11 16l-4-4m0 0l4-4m-4 4h14m-5 4v1m-3-1v1m-3-1v1m-3-1v1m-3-1v1a6 6 0 006 6h2a6 6 0 006-6v-1', // Login icon
  register: 'M18 9v3m0 0v3m0-3h3m-3 0h-3m-2-5a4 4 0 11-8 0 4 4 0 018 0zM3 20a6 6 0 0112 0v1H3v-1z', // User plus icon
};

// Define the main menu items for the desktop sidebar (top section)
export const desktopMenuItems = [
  {
    name: 'Ohjauspaneli', // Dashboard
    path: '/dashboard',
    icon: SVG_ICONS.dashboard,
  },
  {
    name: 'Päiväkirja', // Sessions
    path: '/sessions',
    icon: SVG_ICONS.sessions,
  },
  {
    name: 'Aseet', // Weapons
    path: '/weapons',
    icon: SVG_ICONS.weapons,
  },
  {
    name: 'Tilastot', // Statistics
    path: '/statistics',
    icon: SVG_ICONS.statistics,
  },
  {
    name: 'Ampumaradat', // Shooting Ranges
    path: '/ranges',
    icon: SVG_ICONS.ranges,
  },
];

// Define the bottom-aligned authentication/profile items for the desktop sidebar
export const desktopBottomAuthItems = [
  {
    name: 'Profiili', // Profile
    path: '/profile',
    icon: SVG_ICONS.profile,
  },
  {
    name: 'Kirjaudu ulos', // Logout
    path: '/logout', // Note: This path will be intercepted for logout logic
    icon: SVG_ICONS.logout,
    action: 'logout' // Custom action to trigger logout
  },
];

// Define the main menu items for the mobile bottom navigation bar
export const mobileBottomNavItems = [
  {
    name: 'Ohjauspaneli', // Dashboard
    path: '/dashboard',
    icon: SVG_ICONS.dashboard,
  },
  {
    name: 'Päiväkirja', // Sessions
    path: '/sessions',
    icon: SVG_ICONS.sessions,
  },
  {
    name: 'Profiili', // Profile
    path: '/profile',
    icon: SVG_ICONS.profile,
  },
];

// Define the menu items that go into the "More" menu on mobile
export const mobileMoreMenuItems = [
  {
    name: 'Aseet', // Weapons
    path: '/weapons',
    icon: SVG_ICONS.weapons,
  },
  {
    name: 'Tilastot', // Statistics
    path: '/statistics',
    icon: SVG_ICONS.statistics,
  },
  {
    name: 'Ampumaradat', // Shooting Ranges
    path: '/ranges',
    icon: SVG_ICONS.ranges,
  },
  // Add login/register here if they should be in the More menu when not authenticated
  // {
  //   name: 'Kirjaudu sisään',
  //   path: '/login',
  //   icon: SVG_ICONS.login,
  // },
  // {
  //   name: 'Rekisteröidy',
  //   path: '/register',
  //   icon: SVG_ICONS.register,
  // },
];
