import { createRouter, createWebHashHistory } from 'vue-router';
import products from '../components/products.vue';
import duplicateProduct from '../components/duplicateProduct.vue';
import viewProduct from '@/components/viewProduct.vue';

const routes = [
    {
        path: '/',
        name: 'Products',
        component: products,
    },
    {
        path: '/view-product',
        name: 'view-product',
        component: viewProduct,
    },
    {
        path: '/new-product',
        name: 'new-product',
        component: duplicateProduct,
    }
];

const router = createRouter({
    mode: 'hash',
    history: createWebHashHistory(),
    routes
});

export default router;