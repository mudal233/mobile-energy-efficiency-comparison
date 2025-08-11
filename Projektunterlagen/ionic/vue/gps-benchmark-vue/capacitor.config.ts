import type { CapacitorConfig } from '@capacitor/cli';

const config: CapacitorConfig = {
  plugins: {
    FreshGps: {
      permissions: ['ACCESS_FINE_LOCATION']
    }
  },
  appId: 'io.ionic.starter',
  appName: 'gps-benchmark-vue',
  webDir: 'dist'
};

export default config;
