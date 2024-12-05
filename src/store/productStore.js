// stores/productStore.js
import { defineStore } from 'pinia';

export const useProductStore = defineStore('product', {
    state: () => ({
        productInfo: JSON.parse(localStorage.getItem('productInfo')) || null,
        instance: localStorage.getItem('instance') || null,
        database: localStorage.getItem('database') || null,
    }),
    actions: {
        setProductInfo(info) {
            this.productInfo = info;
            localStorage.setItem('productInfo', JSON.stringify(info));
        },
        clearProductInfo() {
            this.productInfo = null;
            localStorage.removeItem('productInfo');
        },
        setInstance(item) {
            this.instance = item;
            localStorage.setItem('instance', item);
        },
        setDatabase(item) {
            this.database = item;
            localStorage.setItem('database', item);
        },
        clearInstanceAndDatabase() {
            this.instance = null;
            this.database = null;
            localStorage.removeItem('instance');
            localStorage.removeItem('database');
        },
    },
});