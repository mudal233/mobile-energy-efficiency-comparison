import { createRouter, createWebHistory } from '@ionic/vue-router';
import TabsPage from '../views/TabsPage.vue';
import HomePage from '../views/HomePage.vue';
import SearchPage from '../views/SearchPage.vue';

const routes = [
  {
    path: '/',
    redirect: '/tabs/home'
  },
  {
    path: '/tabs/',
    component: TabsPage,
    children: [
      {
        path: '',
        redirect: '/tabs/home'
      },
      {
        path: 'home',
        component: HomePage
      },
      {
        path: 'search',
        component: SearchPage
      },
      {
        path: 'manual',
        component: () => import('../views/ManuelleEingabePage.vue')
      },
      {
        path: 'update',
        component: () => import('../views/UpdateNotizPage.vue')
      }
    ]
  }
];

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes
});

export default router;
